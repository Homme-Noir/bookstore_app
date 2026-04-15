import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../features/library/domain/models/library_item.dart';
import '../../features/reader/domain/models/reader_annotation.dart';
import '../../features/reader/domain/models/reading_progress.dart';
import 'local_database.dart';

class BackupService {
  BackupService({required LocalDatabase database}) : _database = database;

  final LocalDatabase _database;

  Future<String> exportJsonSnapshot() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/library_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    final payload = {
      'library_items': await _database.customSelect('SELECT * FROM local_library_items'),
      'reading_progress': await _database.customSelect('SELECT * FROM local_reading_progress'),
      'annotations': await _database.customSelect('SELECT * FROM local_annotations'),
      'retry_jobs': await _database.customSelect('SELECT * FROM sync_retry_jobs'),
      'created_at': DateTime.now().toIso8601String(),
    };
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file.path;
  }

  Future<String?> verifySnapshot(String path) async {
    try {
      final raw = await File(path).readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return 'Backup is not a JSON object';
      }
      const requiredKeys = <String>[
        'library_items',
        'reading_progress',
        'annotations',
        'retry_jobs',
        'created_at',
      ];
      for (final key in requiredKeys) {
        if (!decoded.containsKey(key)) {
          return 'Missing key: $key';
        }
      }
      if (decoded['library_items'] is! List ||
          decoded['reading_progress'] is! List ||
          decoded['annotations'] is! List ||
          decoded['retry_jobs'] is! List) {
        return 'Backup structure is invalid';
      }
      return null;
    } catch (e) {
      return 'Failed to parse backup: $e';
    }
  }

  Future<void> importJsonSnapshot(String path) async {
    final problem = await verifySnapshot(path);
    if (problem != null) {
      throw StateError(problem);
    }

    final raw = await File(path).readAsString();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final libraryRows = (decoded['library_items'] as List).cast<Map>();
    final progressRows = (decoded['reading_progress'] as List).cast<Map>();
    final annotationRows = (decoded['annotations'] as List).cast<Map>();
    final retryRows = (decoded['retry_jobs'] as List).cast<Map>();

    await _database.customStatement('DELETE FROM local_library_items');
    await _database.customStatement('DELETE FROM local_reading_progress');
    await _database.customStatement('DELETE FROM local_annotations');
    await _database.customStatement('DELETE FROM sync_retry_jobs');

    final items = libraryRows.map((row) {
      final data = Map<String, dynamic>.from(row);
      return LibraryItem(
        id: data['id'] as String,
        title: data['title'] as String? ?? 'Untitled',
        author: data['author'] as String? ?? 'Unknown Author',
        filePath: data['file_path'] as String? ?? '',
        format: data['format'] as String? ?? 'unknown',
        sourceUrl: data['source_url'] as String?,
        checksum: data['checksum'] as String?,
        createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(data['updated_at'] as String? ?? '') ??
            DateTime.now(),
        progress: (data['progress'] as num?)?.toDouble() ?? 0,
        isFinished: (data['is_finished'] as int? ?? 0) == 1,
        tags: ((jsonDecode(data['tags_json'] as String? ?? '[]') as List))
            .cast<String>(),
      );
    }).toList();
    await _database.saveLibraryItems(items);

    for (final row in progressRows) {
      final data = Map<String, dynamic>.from(row);
      await _database.upsertProgress(
        ReadingProgress(
          itemId: data['item_id'] as String,
          percentage: (data['percentage'] as num?)?.toDouble() ?? 0,
          position: data['position'] as int? ?? 0,
          updatedAt:
              DateTime.tryParse(data['updated_at'] as String? ?? '') ?? DateTime.now(),
        ),
      );
    }

    for (final row in annotationRows) {
      final data = Map<String, dynamic>.from(row);
      await _database.insertAnnotation(
        ReaderAnnotation(
          id: data['id'] as String,
          itemId: data['item_id'] as String,
          annotationId: data['annotation_id'] as String? ?? data['id'] as String,
          note: data['note'] as String? ?? '',
          start: data['start_position'] as int? ?? 0,
          end: data['end_position'] as int? ?? 0,
          createdAt:
              DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now(),
          updatedAt:
              DateTime.tryParse(data['updated_at'] as String? ?? '') ?? DateTime.now(),
          version: data['version'] as int? ?? 1,
          isDeleted: (data['is_deleted'] as int? ?? 0) == 1,
        ),
      );
    }

    for (final row in retryRows) {
      final data = Map<String, dynamic>.from(row);
      await _database.customStatement(
        '''
        INSERT INTO sync_retry_jobs
          (job_type, payload_json, attempts, status, last_error, next_retry_at, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          data['job_type'] as String? ?? 'unknown',
          data['payload_json'] as String? ?? '{}',
          data['attempts'] as int? ?? 0,
          data['status'] as String? ?? 'queued',
          data['last_error'] as String?,
          data['next_retry_at'] as String? ?? DateTime.now().toIso8601String(),
          data['created_at'] as String? ?? DateTime.now().toIso8601String(),
        ],
      );
    }
  }
}

