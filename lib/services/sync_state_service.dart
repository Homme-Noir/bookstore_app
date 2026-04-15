import '../core/security/secure_kv_store.dart';

/// Persists incremental sync metadata (last run time, opaque cursor) securely.
class SyncStateService {
  SyncStateService({SecureKvStore? secureStore})
      : _secureStore = secureStore ?? const SecureKvStore();

  final SecureKvStore _secureStore;

  static const _lastSyncAtKey = 'sync_last_completed_at';
  static const _syncCursorKey = 'sync_cursor';

  Future<void> setLastSyncAt(DateTime timestamp) {
    return _secureStore.write(_lastSyncAtKey, timestamp.toIso8601String());
  }

  Future<DateTime?> getLastSyncAt() async {
    final raw = await _secureStore.read(_lastSyncAtKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setSyncCursor(String cursor) {
    return _secureStore.write(_syncCursorKey, cursor);
  }

  Future<String?> getSyncCursor() => _secureStore.read(_syncCursorKey);
}

