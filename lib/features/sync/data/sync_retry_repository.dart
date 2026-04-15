import 'dart:convert';

import '../../../core/storage/local_database.dart';
import '../domain/models/retry_job.dart';

class SyncRetryRepository {
  SyncRetryRepository({required LocalDatabase database}) : _database = database;

  final LocalDatabase _database;

  Future<void> enqueue({
    required String jobType,
    required Map<String, dynamic> payload,
  }) {
    return _database.enqueueRetryJob(
      jobType: jobType,
      payloadJson: jsonEncode(payload),
    );
  }

  Future<List<RetryJob>> dueJobs({int limit = 25}) async {
    final rows = await _database.listDueRetryJobs(limit: limit);
    return _mapRows(rows);
  }

  Future<void> markDone(int id) => _database.deleteRetryJob(id);

  Future<void> markFailed(RetryJob job, {String? error}) async {
    if (error != null && error.isNotEmpty) {
      await _database.setRetryError(job.id, error);
    }
    await _database.postponeRetryJob(job.id, job.attempts + 1);
  }

  Future<List<RetryJob>> listJobs({int limit = 100}) async {
    final rows = await _database.listRetryJobs(limit: limit);
    return _mapRows(rows);
  }

  Future<void> retryNow(int id) => _database.forceRetryNow(id);

  List<RetryJob> _mapRows(List<Map<String, Object?>> rows) {
    return rows
        .map(
          (row) => RetryJob(
            id: row['id'] as int,
            jobType: row['job_type'] as String,
            payloadJson: row['payload_json'] as String,
            attempts: row['attempts'] as int? ?? 0,
            status: row['status'] as String? ?? 'queued',
            lastError: row['last_error'] as String?,
            nextRetryAt: DateTime.parse(row['next_retry_at'] as String),
            createdAt: DateTime.parse(row['created_at'] as String),
          ),
        )
        .toList();
  }
}

