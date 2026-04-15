import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/observability/telemetry_service.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../../sync/data/sync_retry_repository.dart';
import '../../data/download_ingest_service.dart';
import '../../data/source_adapter.dart';
import '../../domain/models/discovery_result.dart';

class DiscoveryProvider extends ChangeNotifier {
  DiscoveryProvider({
    required List<SourceAdapter> adapters,
    required DownloadIngestService ingestService,
    required SyncRetryRepository retryRepository,
    this.discoveryApiBaseUrl,
    http.Client? httpClient,
  })  : _adapters = adapters,
        _ingestService = ingestService,
        _retryRepository = retryRepository,
        _httpClient = httpClient ?? http.Client();

  final List<SourceAdapter> _adapters;
  final DownloadIngestService _ingestService;
  final SyncRetryRepository _retryRepository;
  final http.Client _httpClient;

  /// When set, used to call `GET /anna/resolve` for Anna `anna-md5-…` hits.
  final String? discoveryApiBaseUrl;

  static const _telemetry = TelemetryService();

  bool _isLoading = false;
  String? _error;
  String _query = '';
  List<DiscoveryResult> _results = [];
  bool _policyAccepted = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<DiscoveryResult> get results => _results;
  bool get policyAccepted => _policyAccepted;

  void setPolicyAccepted(bool value) {
    _policyAccepted = value;
    notifyListeners();
  }

  /// Runs discovery with title + author to surface downloadable mirrors.
  Future<void> searchForDownloadableCopy({
    required String title,
    required String author,
  }) async {
    final q = [title.trim(), author.trim()]
        .where((s) => s.isNotEmpty)
        .join(' ');
    await search(q.isEmpty ? title.trim() : q);
  }

  String _dedupeKey(DiscoveryResult r) =>
      '${r.title.toLowerCase().trim()}|${r.author.toLowerCase().trim()}';

  DiscoveryResult _preferRicherResult(DiscoveryResult a, DiscoveryResult b) {
    final aHas = a.canAcquire;
    final bHas = b.canAcquire;
    if (aHas != bHas) {
      return aHas ? a : b;
    }
    if ((a.confidence - b.confidence).abs() > 0.0001) {
      return a.confidence >= b.confidence ? a : b;
    }
    return a.source.length <= b.source.length ? a : b;
  }

  Future<void> search(String query) async {
    _query = query.trim();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final merged = <String, DiscoveryResult>{};
      for (final adapter in _adapters) {
        final partial = await adapter.search(_query);
        for (final item in partial) {
          final key = _dedupeKey(item);
          final existing = merged[key];
          if (existing == null) {
            merged[key] = item;
          } else {
            merged[key] = _preferRicherResult(existing, item);
          }
        }
      }
      _results = merged.values.toList()
        ..sort((a, b) => b.confidence.compareTo(a.confidence));
      _telemetry.event('discovery.search', {'query': _query, 'count': _results.length});
    } catch (e) {
      _telemetry.event('discovery.failure', {'query': _query, 'error': e.toString()});
      _error = 'Discovery failed. Please retry.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static final _annaMd5Re = RegExp(r'^anna-md5-([a-f0-9]{32})$');

  String? _annaMd5FromId(String id) {
    final m = _annaMd5Re.firstMatch(id.trim());
    return m?.group(1);
  }

  Future<Map<String, dynamic>?> _resolveAnnaMd5(String md5) async {
    final base = discoveryApiBaseUrl?.trim();
    if (base == null || base.isEmpty) return null;
    final root = base.replaceAll(RegExp(r'/+$'), '');
    final uri =
        Uri.parse('$root/anna/resolve').replace(queryParameters: {'md5': md5});
    try {
      final r = await _httpClient.get(uri);
      if (r.statusCode < 200 || r.statusCode >= 300) return null;
      final decoded = jsonDecode(r.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String> _launchMagnet(String magnet) async {
    final uri = Uri.tryParse(magnet.trim());
    if (uri == null || uri.scheme != 'magnet') {
      return 'Invalid magnet link.';
    }
    final ok =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    return ok
        ? 'Opened torrent link in an external app. Import the file here when it finishes.'
        : 'Could not open the magnet link.';
  }

  /// Resolve Anna metadata, then HTTP-import and/or open a magnet link.
  Future<String> downloadAndImport({
    required DiscoveryResult result,
    required LibraryProvider libraryProvider,
  }) async {
    if (!_policyAccepted) {
      return 'You must accept legal responsibility first.';
    }

    var url = result.downloadUrl?.trim();
    var magnet = result.magnetUrl?.trim();

    final md5 = result.source == 'AnnaArchive' ? _annaMd5FromId(result.id) : null;
    if ((url == null || url.isEmpty) &&
        (magnet == null || magnet.isEmpty) &&
        md5 != null) {
      final resolved = await _resolveAnnaMd5(md5);
      if (resolved != null) {
        final du = resolved['download_url']?.toString().trim();
        final mu = resolved['magnet_url']?.toString().trim();
        final note = resolved['note']?.toString();
        if (du != null && du.isNotEmpty) url = du;
        if (mu != null && mu.isNotEmpty) magnet = mu;
        if ((url == null || url.isEmpty) &&
            (magnet == null || magnet.isEmpty) &&
            note != null &&
            note.isNotEmpty) {
          return note;
        }
      } else if (discoveryApiBaseUrl == null ||
          discoveryApiBaseUrl!.trim().isEmpty) {
        return 'Anna results need the discovery API (set DISCOVERY_API_BASE_URL) '
            'to resolve download links, or open the catalog page in a browser.';
      }
    }

    if (url != null && url.isNotEmpty) {
      final ingest = await _ingestService.downloadBook(
        url,
        suggestedName: result.title,
      );
      if (!ingest.allowed || ingest.filePath == null) {
        _telemetry.event('ingest.blocked', {'url': url});
        await _retryRepository.enqueue(
          jobType: 'download',
          payload: {
            'url': url,
            'title': result.title,
            'author': result.author,
          },
        );
        return ingest.reason ?? 'Download blocked';
      }
      await libraryProvider.addImportedFile(
        path: ingest.filePath!,
        title: result.title,
        author: result.author,
        sourceUrl: url,
        checksum: ingest.checksum,
      );
      _telemetry.event('ingest.success', {'title': result.title, 'source': result.source});
      return 'Imported ${result.title}';
    }

    if (magnet != null && magnet.isNotEmpty) {
      _telemetry.event('ingest.magnet', {'title': result.title});
      return _launchMagnet(magnet);
    }

    return 'No direct download or torrent link for this result. '
        'Try “Find file”, or open the catalog link in a browser.';
  }

  Future<String> downloadFromUrl({
    required String url,
    required String title,
    required String author,
    required LibraryProvider libraryProvider,
  }) async {
    if (!_policyAccepted) {
      return 'You must accept legal responsibility first.';
    }
    final trimmed = url.trim();
    if (trimmed.toLowerCase().startsWith('magnet:')) {
      return _launchMagnet(trimmed);
    }
    final ingest = await _ingestService.downloadBook(
      trimmed,
      suggestedName: title,
    );
    if (!ingest.allowed || ingest.filePath == null) {
      await _retryRepository.enqueue(
        jobType: 'download',
        payload: {
          'url': trimmed,
          'title': title,
          'author': author,
        },
      );
      return ingest.reason ?? 'Download blocked';
    }
    await libraryProvider.addImportedFile(
      path: ingest.filePath!,
      title: title,
      author: author,
      sourceUrl: trimmed,
      checksum: ingest.checksum,
    );
    return 'Downloaded and imported $title';
  }

  Future<int> retryQueuedDownloads({
    required LibraryProvider libraryProvider,
  }) async {
    final jobs = await _retryRepository.dueJobs(limit: 20);
    var completed = 0;
    for (final job in jobs.where((entry) => entry.jobType == 'download')) {
      try {
        final decoded = job.payloadJson.isEmpty
            ? <String, dynamic>{}
            : Map<String, dynamic>.from(jsonDecode(job.payloadJson) as Map);
        final url = decoded['url']?.toString();
        final title = decoded['title']?.toString() ?? 'Downloaded Book';
        final author = decoded['author']?.toString() ?? 'Unknown Author';
        if (url == null || url.isEmpty) {
          await _retryRepository.markDone(job.id);
          continue;
        }

        if (url.trim().toLowerCase().startsWith('magnet:')) {
          await _retryRepository.markFailed(
            job,
            error: 'Magnet links cannot be retried automatically.',
          );
          continue;
        }

        final result = await _ingestService.downloadBook(
          url,
          suggestedName: title,
        );
        if (!result.allowed || result.filePath == null) {
          await _retryRepository.markFailed(
            job,
            error: result.reason ?? 'Download rejected by ingest policy.',
          );
          continue;
        }

        await libraryProvider.addImportedFile(
          path: result.filePath!,
          title: title,
          author: author,
          sourceUrl: url,
          checksum: result.checksum,
        );
        await _retryRepository.markDone(job.id);
        completed++;
      } catch (e) {
        await _retryRepository.markFailed(job, error: e.toString());
      }
    }
    return completed;
  }
}
