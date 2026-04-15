import 'dart:convert';

import 'package:http/http.dart' as http;

/// Resolves a direct [.epub] / [.pdf] URL on archive.org from Internet Archive item ids.
///
/// Open Library search results often include an `ia` field; many items host lendable
/// or public-domain files we can import after the user accepts policy.
class InternetArchiveDownloadResolver {
  InternetArchiveDownloadResolver({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// Tries each [iaIds] in order (newest ids tend to be listed first in OL).
  Future<String?> firstDirectDownloadUrl(
    List<String> iaIds, {
    int maxAttempts = 4,
  }) async {
    for (final id in iaIds.take(maxAttempts)) {
      final trimmed = id.trim();
      if (trimmed.isEmpty) continue;
      final url = await _resolveSingle(trimmed);
      if (url != null) return url;
    }
    return null;
  }

  Future<String?> _resolveSingle(String iaId) async {
    final uri = Uri.parse(
      'https://archive.org/metadata/${Uri.encodeComponent(iaId)}',
    );
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final files = decoded['files'];
      if (files is! List) return null;
      String? epubName;
      String? pdfName;
      for (final raw in files) {
        if (raw is! Map) continue;
        final name = raw['name']?.toString() ?? '';
        final lower = name.toLowerCase();
        if (lower.endsWith('.epub')) {
          epubName ??= name;
        } else if (lower.endsWith('.pdf')) {
          pdfName ??= name;
        }
      }
      final pick = epubName ?? pdfName;
      if (pick == null || pick.isEmpty) return null;
      return 'https://archive.org/download/$iaId/${Uri.encodeComponent(pick)}';
    } catch (_) {
      return null;
    }
  }
}
