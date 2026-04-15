import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/models/discovery_result.dart';
import 'source_adapter.dart';

class AnnaArchiveSourceAdapter implements SourceAdapter {
  AnnaArchiveSourceAdapter({
    required String? baseUrl,
    this.includeAnna = false,
    http.Client? client,
  })  : _baseUrl = baseUrl?.trim() ?? '',
        _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  final bool includeAnna;

  @override
  String get name => 'anna-archive';

  @override
  Future<List<DiscoveryResult>> search(String query) async {
    if (_baseUrl.isEmpty || query.trim().isEmpty) {
      return const [];
    }

    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'query': query.trim(),
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
        .map((raw) => Map<String, dynamic>.from(raw))
        .map(_toResult)
        .toList();
  }

  DiscoveryResult _toResult(Map<String, dynamic> row) {
    final downloadUrl = row['download_url']?.toString();
    final magnetUrl = row['magnet_url']?.toString();
    final format = row['format']?.toString().toLowerCase() ?? 'unknown';
    final confidence = (row['confidence'] as num?)?.toDouble() ?? 0.7;
    return DiscoveryResult(
      id: row['id']?.toString() ?? 'anna-${DateTime.now().millisecondsSinceEpoch}',
      title: row['title']?.toString() ?? 'Untitled',
      author: row['author']?.toString() ?? 'Unknown',
      source: 'AnnaArchive',
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

