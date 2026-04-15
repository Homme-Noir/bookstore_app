import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/resolved_runtime_config.dart';
import '../features/library/domain/models/library_item.dart';
import '../features/reader/domain/models/reader_annotation.dart';
import '../features/reader/domain/models/reading_progress.dart';
import '../features/sync/domain/conflict_resolver.dart';

/// Pushes and pulls library items, progress, and annotations via Supabase PostgREST.
///
/// No-ops when Supabase env vars are missing or the user is signed out.
/// Uses [ConflictResolver] so local and remote merges stay deterministic.
class SupabaseSyncService {
  const SupabaseSyncService({ConflictResolver? conflictResolver})
      : _conflictResolver = conflictResolver ?? const ConflictResolver();

  final ConflictResolver _conflictResolver;

  bool get isConfigured => ResolvedRuntimeConfig.instance.isSupabaseConfigured;

  Future<String> syncSummary() async {
    if (!isConfigured) {
      return 'Sync inactive (Supabase environment not configured).';
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return 'Sync ready. Sign in to sync across devices.';
    }

    return 'Sync ready for ${user.email ?? user.id}.';
  }

  Future<String> schemaGuardCheck() async {
    if (!isConfigured) return 'schema-check skipped (Supabase not configured)';
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return 'schema-check skipped (not authenticated)';
    try {
      await Supabase.instance.client
          .from('library_items')
          .select('id')
          .eq('user_id', user.id)
          .limit(1);
      await Supabase.instance.client
          .from('reading_progress')
          .select('library_item_id')
          .eq('user_id', user.id)
          .limit(1);
      await Supabase.instance.client
          .from('annotations')
          .select('annotation_id')
          .eq('user_id', user.id)
          .limit(1);
      return 'schema-check ok';
    } catch (e) {
      return 'schema-check failed: $e';
    }
  }

  Future<List<LibraryItem>> syncLibraryItems(
    List<LibraryItem> localItems, {
    DateTime? changedSince,
  }) async {
    if (!isConfigured) return localItems;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return localItems;

    final payload = localItems
        .map(
          (item) => {
            'id': item.id,
            'user_id': user.id,
            'title': item.title,
            'author': item.author,
            'format': item.format,
            'source': 'local',
            'source_url': item.sourceUrl,
            'checksum': item.checksum,
            'is_deleted': false,
            'tags': item.tags,
            'created_at': item.createdAt.toIso8601String(),
            'updated_at': item.updatedAt.toIso8601String(),
          },
        )
        .toList();

    if (payload.isNotEmpty) {
      await Supabase.instance.client
          .from('library_items')
          .upsert(payload, onConflict: 'id');
    }

    var remoteQuery = Supabase.instance.client
        .from('library_items')
        .select()
        .eq('user_id', user.id);
    if (changedSince != null) {
      remoteQuery =
          remoteQuery.gte('updated_at', changedSince.toIso8601String());
    }
    final remote = await remoteQuery;

    final byId = <String, LibraryItem>{
      for (final item in localItems) item.id: item
    };
    for (final row in remote) {
      final id = row['id'] as String;
      final remoteUpdated =
          DateTime.tryParse(row['updated_at'] as String? ?? '') ??
              DateTime.now();
      final existing = byId[id];
      final isDeleted = row['is_deleted'] as bool? ?? false;
      if (isDeleted && existing != null) {
        byId.remove(id);
        continue;
      }
      final remoteItem = LibraryItem(
        id: id,
        title: row['title'] as String? ?? 'Untitled',
        author: row['author'] as String? ?? 'Unknown Author',
        filePath: existing?.filePath ?? '',
        format: row['format'] as String? ?? (existing?.format ?? 'unknown'),
        sourceUrl: row['source_url'] as String? ?? existing?.sourceUrl,
        checksum: row['checksum'] as String? ?? existing?.checksum,
        createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
            existing?.createdAt ??
            DateTime.now(),
        updatedAt: remoteUpdated,
        progress: existing?.progress ?? 0,
        isFinished: existing?.isFinished ?? false,
        tags: (row['tags'] as List<dynamic>? ?? const []).cast<String>(),
      );
      if (existing == null) {
        byId[id] = remoteItem;
      } else if (remoteUpdated.isAfter(existing.updatedAt) ||
          existing.updatedAt.isAfter(remoteUpdated)) {
        byId[id] = _conflictResolver.mergeLibraryItem(
          local: existing,
          remote: remoteItem,
        );
      }
    }

    return byId.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<List<ReadingProgress>> syncReadingProgress(
    List<ReadingProgress> localProgress, {
    DateTime? changedSince,
  }) async {
    if (!isConfigured) return localProgress;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return localProgress;

    final payload = localProgress
        .map(
          (item) => {
            'user_id': user.id,
            'library_item_id': item.itemId,
            'percentage': item.percentage,
            'position': item.position,
            'device_id': 'flutter-client',
            'updated_at': item.updatedAt.toIso8601String(),
            'version': 1,
          },
        )
        .toList();

    if (payload.isNotEmpty) {
      await Supabase.instance.client
          .from('reading_progress')
          .upsert(payload, onConflict: 'user_id,library_item_id');
    }

    var remoteQuery = Supabase.instance.client
        .from('reading_progress')
        .select()
        .eq('user_id', user.id);
    if (changedSince != null) {
      remoteQuery =
          remoteQuery.gte('updated_at', changedSince.toIso8601String());
    }
    final remote = await remoteQuery;

    final byId = <String, ReadingProgress>{
      for (final item in localProgress) item.itemId: item,
    };

    for (final row in remote) {
      final itemId = row['library_item_id'] as String;
      final remoteUpdated =
          DateTime.tryParse(row['updated_at'] as String? ?? '') ??
              DateTime.now();
      final candidate = ReadingProgress(
        itemId: itemId,
        percentage: (row['percentage'] as num?)?.toDouble() ?? 0,
        position: row['position'] as int? ?? 0,
        updatedAt: remoteUpdated,
      );
      final existing = byId[itemId];
      if (existing == null) {
        byId[itemId] = candidate;
      } else {
        byId[itemId] = _conflictResolver.mergeReadingProgress(
          local: existing,
          remote: candidate,
        );
      }
    }

    return byId.values.toList();
  }

  Future<List<ReaderAnnotation>> syncAnnotations(
    List<ReaderAnnotation> localAnnotations, {
    DateTime? changedSince,
  }) async {
    if (!isConfigured) return localAnnotations;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return localAnnotations;

    final payload = localAnnotations
        .map(
          (item) => {
            'user_id': user.id,
            'library_item_id': item.itemId,
            'annotation_id': item.annotationId,
            'note': item.note,
            'start_position': item.start,
            'end_position': item.end,
            'version': item.version,
            'updated_at': item.updatedAt.toIso8601String(),
            'is_deleted': item.isDeleted,
          },
        )
        .toList();

    if (payload.isNotEmpty) {
      await Supabase.instance.client
          .from('annotations')
          .upsert(payload, onConflict: 'user_id,annotation_id');
    }

    var remoteQuery = Supabase.instance.client
        .from('annotations')
        .select()
        .eq('user_id', user.id);
    if (changedSince != null) {
      remoteQuery =
          remoteQuery.gte('updated_at', changedSince.toIso8601String());
    }
    final remote = await remoteQuery;

    final merged = <String, ReaderAnnotation>{
      for (final item in localAnnotations) item.annotationId: item,
    };

    for (final row in remote) {
      final annotationId = row['annotation_id'] as String;
      final remoteUpdated =
          DateTime.tryParse(row['updated_at'] as String? ?? '') ??
              DateTime.now();
      final candidate = ReaderAnnotation(
        id: '${row['library_item_id']}_$annotationId',
        itemId: row['library_item_id'] as String,
        annotationId: annotationId,
        note: row['note'] as String? ?? '',
        start: row['start_position'] as int? ?? 0,
        end: row['end_position'] as int? ?? 0,
        createdAt: remoteUpdated,
        updatedAt: remoteUpdated,
        version: row['version'] as int? ?? 1,
        isDeleted: row['is_deleted'] as bool? ?? false,
      );

      final existing = merged[annotationId];
      if (existing == null) {
        merged[annotationId] = candidate;
      } else {
        merged[annotationId] = _conflictResolver.mergeAnnotation(
          local: existing,
          remote: candidate,
        );
      }
    }

    return merged.values.toList();
  }
}
