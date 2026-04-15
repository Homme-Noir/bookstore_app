/// Drift-backed SQLite store for catalog, reader state, annotations, and sync jobs.
library;

import 'dart:io';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/library/domain/models/library_item.dart';
import '../../features/reader/domain/models/reader_annotation.dart';
import '../../features/reader/domain/models/reading_progress.dart';

/// Opens the raw [NativeDatabase] without generated drift migrations; schema is
/// applied manually in [_init].
final class _ManualDbUser implements QueryExecutorUser {
  const _ManualDbUser();

  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}
}

const _manualDbUser = _ManualDbUser();

/// Application file database under the app documents directory (`library_sync.sqlite`).
///
/// Tables are created idempotently on first open. Repositories in `features/*/data/`
/// encapsulate queries; this class keeps raw SQL migrations minimal for clarity.
class LocalDatabase {
  LocalDatabase._(this._db);

  final QueryExecutor _db;
  bool _initialized = false;

  static Future<LocalDatabase> create() async {
    final documents = await getApplicationDocumentsDirectory();
    final file = File('${documents.path}/library_sync.sqlite');
    final executor = NativeDatabase(file);
    await executor.ensureOpen(_manualDbUser);
    final database = LocalDatabase._(executor);
    await database._init();
    return database;
  }

  Future<void> _init() async {
    if (_initialized) {
      return;
    }
    await customStatement('''
      CREATE TABLE IF NOT EXISTS local_library_items (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        file_path TEXT NOT NULL,
        format TEXT NOT NULL,
        source_url TEXT,
        checksum TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        progress REAL NOT NULL,
        is_finished INTEGER NOT NULL,
        tags_json TEXT NOT NULL
      );
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS local_reading_progress (
        item_id TEXT PRIMARY KEY,
        percentage REAL NOT NULL,
        position INTEGER NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS local_annotations (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        annotation_id TEXT NOT NULL,
        note TEXT NOT NULL,
        start_position INTEGER NOT NULL,
        end_position INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        version INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL
      );
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS sync_retry_jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        job_type TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'queued',
        last_error TEXT,
        next_retry_at TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');
    await _ensureColumn('sync_retry_jobs', 'status', "TEXT NOT NULL DEFAULT 'queued'");
    await _ensureColumn('sync_retry_jobs', 'last_error', 'TEXT');
    await _ensureColumn('local_library_items', 'source_url', 'TEXT');
    await _ensureColumn('local_library_items', 'checksum', 'TEXT');
    await _ensureColumn('local_annotations', 'annotation_id', 'TEXT');
    await _ensureColumn('local_annotations', 'updated_at', 'TEXT');
    await _ensureColumn('local_annotations', 'version', 'INTEGER NOT NULL DEFAULT 1');
    await _ensureColumn(
      'local_annotations',
      'is_deleted',
      'INTEGER NOT NULL DEFAULT 0',
    );
    _initialized = true;
  }

  Future<void> _ensureColumn(String table, String column, String type) async {
    final columns = await customSelect('PRAGMA table_info($table)');
    final exists = columns.any((entry) => entry['name'] == column);
    if (!exists) {
      await customStatement('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  Future<void> customStatement(String sql, [List<Object?> args = const []]) {
    return _db.runCustom(sql, args);
  }

  Future<List<Map<String, Object?>>> customSelect(
    String sql, {
    List<Object?> variables = const [],
  }) {
    return _db.runSelect(sql, variables);
  }

  Future<List<LibraryItem>> listLibraryItems() async {
    final rows = await customSelect(
      '''
      SELECT id, title, author, file_path, format, source_url, checksum,
             created_at, updated_at,
             progress, is_finished, tags_json
      FROM local_library_items
      ORDER BY updated_at DESC
      ''',
    );

    return rows.map((row) {
      final rawTags = row['tags_json'] as String? ?? '[]';
      final tags = (jsonDecode(rawTags) as List<dynamic>).cast<String>();
      return LibraryItem(
        id: row['id'] as String,
        title: row['title'] as String,
        author: row['author'] as String,
        filePath: row['file_path'] as String,
        format: row['format'] as String,
        sourceUrl: row['source_url'] as String?,
        checksum: row['checksum'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
        progress: (row['progress'] as num).toDouble(),
        isFinished: (row['is_finished'] as int) == 1,
        tags: tags,
      );
    }).toList();
  }

  Future<void> saveLibraryItems(List<LibraryItem> items) async {
    await customStatement('DELETE FROM local_library_items');
    for (final item in items) {
      final tags = jsonEncode(item.tags);
      await customStatement(
        '''
        INSERT OR REPLACE INTO local_library_items
          (id, title, author, file_path, format, source_url, checksum,
           created_at, updated_at,
           progress, is_finished, tags_json)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          item.id,
          item.title,
          item.author,
          item.filePath,
          item.format,
          item.sourceUrl,
          item.checksum,
          item.createdAt.toIso8601String(),
          item.updatedAt.toIso8601String(),
          item.progress,
          item.isFinished ? 1 : 0,
          tags,
        ],
      );
    }
  }

  Future<Map<String, ReadingProgress>> listProgress() async {
    final rows = await customSelect(
      '''
      SELECT item_id, percentage, position, updated_at
      FROM local_reading_progress
      ''',
    );
    final map = <String, ReadingProgress>{};
    for (final row in rows) {
      final progress = ReadingProgress(
        itemId: row['item_id'] as String,
        percentage: (row['percentage'] as num).toDouble(),
        position: row['position'] as int,
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );
      map[progress.itemId] = progress;
    }
    return map;
  }

  Future<void> upsertProgress(ReadingProgress progress) {
    return customStatement(
      '''
      INSERT OR REPLACE INTO local_reading_progress
        (item_id, percentage, position, updated_at)
      VALUES (?, ?, ?, ?)
      ''',
      [
        progress.itemId,
        progress.percentage,
        progress.position,
        progress.updatedAt.toIso8601String(),
      ],
    );
  }

  Future<Map<String, List<ReaderAnnotation>>> listAnnotations() async {
    final rows = await customSelect(
      '''
      SELECT id, item_id, annotation_id, note, start_position, end_position,
             created_at, updated_at, version, is_deleted
      FROM local_annotations
      ORDER BY updated_at DESC
      ''',
    );
    final map = <String, List<ReaderAnnotation>>{};
    for (final row in rows) {
      final itemId = row['item_id'] as String;
      final annotation = ReaderAnnotation(
        id: row['id'] as String,
        itemId: itemId,
        annotationId: row['annotation_id'] as String? ?? row['id'] as String,
        note: row['note'] as String,
        start: row['start_position'] as int,
        end: row['end_position'] as int,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(
          (row['updated_at'] as String?) ?? (row['created_at'] as String),
        ),
        version: row['version'] as int? ?? 1,
        isDeleted: (row['is_deleted'] as int? ?? 0) == 1,
      );
      map.putIfAbsent(itemId, () => <ReaderAnnotation>[]).add(annotation);
    }
    return map;
  }

  Future<void> insertAnnotation(ReaderAnnotation annotation) {
    return customStatement(
      '''
      INSERT OR REPLACE INTO local_annotations
        (id, item_id, annotation_id, note, start_position, end_position,
         created_at, updated_at, version, is_deleted)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        annotation.id,
        annotation.itemId,
        annotation.annotationId,
        annotation.note,
        annotation.start,
        annotation.end,
        annotation.createdAt.toIso8601String(),
        annotation.updatedAt.toIso8601String(),
        annotation.version,
        annotation.isDeleted ? 1 : 0,
      ],
    );
  }

  Future<void> enqueueRetryJob({
    required String jobType,
    required String payloadJson,
    DateTime? nextRetryAt,
  }) {
    final now = DateTime.now();
    return customStatement(
      '''
      INSERT INTO sync_retry_jobs
        (job_type, payload_json, attempts, status, next_retry_at, created_at)
      VALUES (?, ?, ?, ?, ?, ?)
      ''',
      [
        jobType,
        payloadJson,
        0,
        'queued',
        (nextRetryAt ?? now).toIso8601String(),
        now.toIso8601String(),
      ],
    );
  }

  Future<List<Map<String, Object?>>> listDueRetryJobs({int limit = 25}) {
    return customSelect(
      '''
      SELECT id, job_type, payload_json, attempts, next_retry_at, created_at
      FROM sync_retry_jobs
      WHERE status = 'queued' AND next_retry_at <= ?
      ORDER BY created_at ASC
      LIMIT ?
      ''',
      variables: [DateTime.now().toIso8601String(), limit],
    );
  }

  Future<void> deleteRetryJob(int id) {
    return customStatement(
      'DELETE FROM sync_retry_jobs WHERE id = ?',
      [id],
    );
  }

  Future<void> postponeRetryJob(int id, int attempts) {
    final delayMinutes = attempts <= 1 ? 1 : (attempts <= 3 ? 5 : 15);
    final next = DateTime.now().add(Duration(minutes: delayMinutes));
    final status = attempts >= 5 ? 'dead_letter' : 'queued';
    return customStatement(
      '''
      UPDATE sync_retry_jobs
      SET attempts = ?, status = ?, next_retry_at = ?
      WHERE id = ?
      ''',
      [attempts, status, next.toIso8601String(), id],
    );
  }

  Future<List<Map<String, Object?>>> listRetryJobs({int limit = 100}) {
    return customSelect(
      '''
      SELECT id, job_type, payload_json, attempts, status, last_error,
             next_retry_at, created_at
      FROM sync_retry_jobs
      ORDER BY created_at DESC
      LIMIT ?
      ''',
      variables: [limit],
    );
  }

  Future<void> forceRetryNow(int id) {
    return customStatement(
      '''
      UPDATE sync_retry_jobs
      SET status = 'queued', next_retry_at = ?
      WHERE id = ?
      ''',
      [DateTime.now().toIso8601String(), id],
    );
  }

  Future<void> setRetryError(int id, String message) {
    return customStatement(
      '''
      UPDATE sync_retry_jobs
      SET last_error = ?
      WHERE id = ?
      ''',
      [message, id],
    );
  }
}

