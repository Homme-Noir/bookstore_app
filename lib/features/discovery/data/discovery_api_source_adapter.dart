import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/models/discovery_result.dart';
import 'source_adapter.dart';

/// Calls the FastAPI discovery service (`GET /search`) and maps results.
/// Use this when [DISCOVERY_API_BASE_URL] points at your hosted API (e.g. Fly.io).
class DiscoveryApiSourceAdapter implements SourceAdapter {
  DiscoveryApiSourceAdapter({
    required String baseUrl,
    this.includeAnna = false,
    http.Client? client,
  })  : _baseUrl = baseUrl.trim(),
        _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  /// When false (default), only Open Library is requested from the discovery API.
  final bool includeAnna;

  @override
  String get name => 'discovery-api';

  @override
  Future<List<DiscoveryResult>> search(String query) async {
    if (_baseUrl.isEmpty) {
      return const [];
    }

    final trimmed = query.trim();
    final effective = trimmed.isEmpty ? 'fiction' : trimmed;

    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'query': effective,
        'include_anna': includeAnna ? 'true' : 'false',
      },
    );
    final response = await _client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return const [];
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return const [];
    final rows = decoded['results'];
    if (rows is! List) return const [];

    return rows
        .whereType<Map>()
        .map((raw) => _mapRow(Map<String, dynamic>.from(raw)))
        .toList();
  }

  DiscoveryResult _mapRow(Map<String, dynamic> row) {
    final downloadUrl = row['download_url']?.toString();
    final magnetUrl = row['magnet_url']?.toString();
    final format = row['format']?.toString().toLowerCase() ?? 'unknown';
    final confidence = (row['confidence'] as num?)?.toDouble() ?? 0.5;
    return DiscoveryResult(
      id: row['id']?.toString() ?? 'unknown',
      title: row['title']?.toString() ?? 'Untitled',
      author: row['author']?.toString() ?? 'Unknown',
      source: row['source']?.toString() ?? 'Discovery',
      format: format,
      coverUrl: row['cover_url']?.toString(),
      downloadUrl: downloadUrl,
      magnetUrl: magnetUrl,
      catalogUrl: row['catalog_url']?.toString(),
      confidence: confidence.clamp(0, 1),
      formatVerified: _looksLikeBookFormat(downloadUrl, format),
      qualityFlags: _qualityFlags(row, downloadUrl, magnetUrl),
    );
  }

  bool _looksLikeBookFormat(String? url, String format) {
    final candidate = (url ?? format).toLowerCase();
    return candidate.contains('.epub') ||
        candidate.contains('.pdf') ||
        candidate.contains('epub') ||
        candidate.contains('pdf');
  }

  List<String> _qualityFlags(
    Map<String, dynamic> row,
    String? url,
    String? magnet,
  ) {
    final flags = <String>[];
    if ((row['title']?.toString() ?? '').isEmpty) flags.add('missing-title');
    if ((row['author']?.toString() ?? '').isEmpty) flags.add('missing-author');
    if ((url == null || url.isEmpty) && (magnet == null || magnet.isEmpty)) {
      flags.add('missing-acquire-url');
    }
    if (flags.isEmpty) flags.add('validated');
    return flags;
  }
}
