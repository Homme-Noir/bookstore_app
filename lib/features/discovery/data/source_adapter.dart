import '../domain/models/discovery_result.dart';

/// Pluggable backend for discovery search (HTTP API, Open Library, Anna, …).
abstract class SourceAdapter {
  String get name;
  Future<List<DiscoveryResult>> search(String query);
}
