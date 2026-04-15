import 'package:flutter/material.dart';

import '../../../discovery/presentation/providers/discovery_provider.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../../reader/presentation/providers/reader_provider.dart';
import '../../../../core/observability/telemetry_service.dart';
import '../../data/sync_retry_repository.dart';
import '../../domain/models/retry_job.dart';
import '../../../../services/supabase_sync_service.dart';
import '../../../../services/sync_state_service.dart';
import '../../../../core/storage/backup_service.dart';

class SyncProvider extends ChangeNotifier {
  SyncProvider({
    required SupabaseSyncService service,
    required SyncRetryRepository retryRepository,
    required SyncStateService stateService,
    required BackupService backupService,
  })  : _service = service,
        _retryRepository = retryRepository,
        _stateService = stateService,
        _backupService = backupService;

  final SupabaseSyncService _service;
  final SyncRetryRepository _retryRepository;
  final SyncStateService _stateService;
  final BackupService _backupService;
  String _status = 'Not synced yet';
  String _schemaStatus = 'Not checked';
  bool _running = false;
  List<RetryJob> _jobs = const [];
  static const _telemetry = TelemetryService();

  String get status => _status;
  String get schemaStatus => _schemaStatus;
  bool get running => _running;
  List<RetryJob> get jobs => _jobs;
  bool get isConfigured => _service.isConfigured;
  Future<DateTime?> get lastSyncedAt => _stateService.getLastSyncAt();

  Future<void> syncNow({
    required LibraryProvider libraryProvider,
    required ReaderProvider readerProvider,
    required DiscoveryProvider discoveryProvider,
  }) async {
    if (_running) return;
    _running = true;
    notifyListeners();
    try {
      final cursor = await _stateService.getSyncCursor();
      final changedSince = cursor == null ? null : DateTime.tryParse(cursor);

      await _retryStaleSyncJobs();
      _status = await _service.syncSummary();
      _schemaStatus = await _service.schemaGuardCheck();
      if (!_service.isConfigured) {
        await refreshJobs();
        return;
      }

      final mergedLibrary = await _service.syncLibraryItems(
        libraryProvider.items,
        changedSince: changedSince,
      );
      await libraryProvider.replaceFromSync(mergedLibrary);

      final mergedProgress = await _service.syncReadingProgress(
        readerProvider.allProgress,
        changedSince: changedSince,
      );
      await readerProvider.applySyncedProgress(mergedProgress);

      final mergedAnnotations = await _service.syncAnnotations(
        readerProvider.allAnnotations,
        changedSince: changedSince,
      );
      await readerProvider.applySyncedAnnotations(mergedAnnotations);

      final retriedDownloads = await discoveryProvider.retryQueuedDownloads(
        libraryProvider: libraryProvider,
      );

      await _clearCompletedSyncJobs();
      final now = DateTime.now();
      await _stateService.setLastSyncAt(now);
      await _stateService.setSyncCursor(now.toIso8601String());
      await refreshJobs();
      _telemetry.event('sync.success', {
        'items': mergedLibrary.length,
        'annotations': mergedAnnotations.length,
        'downloadsRetried': retriedDownloads,
      });

      _status =
          'Sync completed: ${mergedLibrary.length} items, '
          '${mergedAnnotations.length} annotations, '
          '$retriedDownloads retried downloads';
    } catch (e) {
      _telemetry.event('sync.failure', {'error': e.toString()});
      await _retryRepository.enqueue(
        jobType: 'sync',
        payload: {
          'reason': e.toString(),
          'at': DateTime.now().toIso8601String(),
        },
      );
      await refreshJobs();
      _status = 'Sync failed. Job queued for retry.';
    } finally {
      _running = false;
      notifyListeners();
    }
  }

  Future<void> _retryStaleSyncJobs() async {
    final jobs = await _retryRepository.dueJobs(limit: 10);
    for (final job in jobs.where((entry) => entry.jobType == 'sync')) {
      await _retryRepository.markFailed(
        job,
        error: 'Automatic retry defers to explicit sync invocation.',
      );
    }
  }

  Future<void> _clearCompletedSyncJobs() async {
    final jobs = await _retryRepository.dueJobs(limit: 50);
    for (final job in jobs.where((entry) => entry.jobType == 'sync')) {
      await _retryRepository.markDone(job.id);
    }
  }

  Future<void> refreshJobs() async {
    _jobs = await _retryRepository.listJobs();
    _schemaStatus = await _service.schemaGuardCheck();
    notifyListeners();
  }

  Future<void> retryJobNow(int id) async {
    await _retryRepository.retryNow(id);
    await refreshJobs();
  }

  Future<void> cancelJob(int id) async {
    await _retryRepository.markDone(id);
    await refreshJobs();
  }

  Future<String> exportBackup() => _backupService.exportJsonSnapshot();

  Future<String?> verifyBackup(String path) => _backupService.verifySnapshot(path);

  Future<void> importBackup(String path) async {
    await _backupService.importJsonSnapshot(path);
    await refreshJobs();
  }

  Future<void> runBackgroundRetry({
    required LibraryProvider libraryProvider,
    required DiscoveryProvider discoveryProvider,
  }) async {
    try {
      await discoveryProvider.retryQueuedDownloads(
        libraryProvider: libraryProvider,
      );
      await refreshJobs();
    } catch (_) {
      // Keep silent for lifecycle-driven retries to avoid noisy UX.
    }
  }
}
