import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DownloadIngestResult {
  final bool allowed;
  final String? reason;
  final String? mimeType;
  final int? contentLength;
  final String? filePath;
  final String? checksum;

  const DownloadIngestResult({
    required this.allowed,
    this.reason,
    this.mimeType,
    this.contentLength,
    this.filePath,
    this.checksum,
  });
}

class _DigestCollector implements Sink<Digest> {
  Digest? value;

  @override
  void add(Digest data) {
    value = data;
  }

  @override
  void close() {}
}

class DownloadIngestService {
  DownloadIngestService({http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  final http.Client _client;

  static const _allowedMimeMarkers = <String>[
    'application/pdf',
    'application/epub+zip',
    'application/octet-stream',
  ];

  static const _allowedExtensions = <String>{'.epub', '.pdf'};
  static const _maxBytes = 250 * 1024 * 1024; // 250MB safety guardrail.
  static const _blockedExtensions = <String>{
    '.exe',
    '.msi',
    '.bat',
    '.sh',
    '.apk',
    '.dmg',
  };

  Future<DownloadIngestResult> preflight(String url) async {
    final trimmed = url.trim();
    if (trimmed.toLowerCase().startsWith('magnet:')) {
      return const DownloadIngestResult(
        allowed: false,
        reason: 'Magnet links open in a torrent app, not in-app',
      );
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !(uri.hasScheme && uri.host.isNotEmpty)) {
      return const DownloadIngestResult(
        allowed: false,
        reason: 'Invalid URL',
      );
    }

    final ext = p.extension(uri.path).toLowerCase();
    if (_blockedExtensions.contains(ext)) {
      return const DownloadIngestResult(
        allowed: false,
        reason: 'Blocked executable extension',
      );
    }

    try {
      final response = await _headWithFallback(uri);
      final mime = (response.headers['content-type'] ?? '').toLowerCase();
      final size = int.tryParse(response.headers['content-length'] ?? '');
      final mimeAllowed =
          _allowedMimeMarkers.any((marker) => mime.contains(marker));
      final extensionAllowed = ext.isEmpty || _allowedExtensions.contains(ext);
      if (size != null && size > _maxBytes) {
        return DownloadIngestResult(
          allowed: false,
          reason:
              'File too large (${(size / (1024 * 1024)).toStringAsFixed(1)} MB)',
          mimeType: mime.isEmpty ? null : mime,
          contentLength: size,
        );
      }
      if (!mimeAllowed && !extensionAllowed) {
        return DownloadIngestResult(
          allowed: false,
          reason: 'Unsupported content type',
          mimeType: mime.isEmpty ? null : mime,
          contentLength: size,
        );
      }
      return DownloadIngestResult(
        allowed: true,
        mimeType: mime.isEmpty ? null : mime,
        contentLength: size,
      );
    } catch (e) {
      return const DownloadIngestResult(
        allowed: false,
        reason: 'Preflight request failed',
      );
    }
  }

  Future<DownloadIngestResult> downloadBook(String url, {String? suggestedName}) async {
    final trimmed = url.trim();
    if (trimmed.toLowerCase().startsWith('magnet:')) {
      return const DownloadIngestResult(
        allowed: false,
        reason: 'Magnet links open in a torrent app, not in-app',
      );
    }

    final check = await preflight(trimmed);
    if (!check.allowed) {
      return check;
    }

    final uri = Uri.parse(trimmed);
    final request = http.Request('GET', uri);
    final streamed = await _client.send(request);

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      return DownloadIngestResult(
        allowed: false,
        reason: 'Download failed with status ${streamed.statusCode}',
      );
    }

    final reported = streamed.contentLength;
    if (reported != null && reported > _maxBytes) {
      return const DownloadIngestResult(
        allowed: false,
        reason: 'File too large',
      );
    }

    final headerMime = (streamed.headers['content-type'] ?? '').toLowerCase();
    final ext = p.extension(uri.path).toLowerCase();
    final extensionAllowed = ext.isEmpty || _allowedExtensions.contains(ext);
    final mimeAllowed =
        _allowedMimeMarkers.any((marker) => headerMime.contains(marker));
    if (!extensionAllowed && !mimeAllowed) {
      return DownloadIngestResult(
        allowed: false,
        reason: 'Extension/content mismatch',
        mimeType: headerMime.isEmpty ? null : headerMime,
      );
    }

    final docs = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory(p.join(docs.path, 'downloads'));
    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync(recursive: true);
    }

    final effectiveExt = p.extension(uri.path).isEmpty ? '.epub' : p.extension(uri.path);
    final filenameBase = (suggestedName ?? p.basenameWithoutExtension(uri.path)).trim();
    final safeBase = filenameBase.isEmpty ? 'downloaded_book' : _sanitize(filenameBase);
    final filePath = p.join(
      downloadsDir.path,
      '${safeBase}_${DateTime.now().millisecondsSinceEpoch}$effectiveExt',
    );
    final file = File(filePath);

    final digestCollector = _DigestCollector();
    final hashSink = sha256.startChunkedConversion(digestCollector);
    var total = 0;
    final sink = file.openWrite();

    try {
      await for (final chunk in streamed.stream.timeout(const Duration(minutes: 30))) {
        total += chunk.length;
        if (total > _maxBytes) {
          await sink.close();
          if (file.existsSync()) file.deleteSync();
          return const DownloadIngestResult(
            allowed: false,
            reason: 'Downloaded file exceeds size limit',
          );
        }
        hashSink.add(chunk);
        sink.add(chunk);
      }
      hashSink.close();
      await sink.flush();
      await sink.close();
    } catch (_) {
      await sink.flush();
      await sink.close();
      if (file.existsSync()) file.deleteSync();
      return const DownloadIngestResult(
        allowed: false,
        reason: 'Download interrupted',
      );
    }

    final digest = digestCollector.value;
    if (digest == null) {
      if (file.existsSync()) file.deleteSync();
      return const DownloadIngestResult(
        allowed: false,
        reason: 'Checksum failed',
      );
    }

    return DownloadIngestResult(
      allowed: true,
      mimeType: check.mimeType,
      contentLength: total,
      filePath: file.path,
      checksum: digest.toString(),
    );
  }

  String _sanitize(String input) {
    final normalized = input.replaceAll(RegExp(r'\s+'), '_');
    return normalized.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '');
  }

  Future<http.Response> _headWithFallback(Uri uri) async {
    final head = await _client.head(uri);
    if (head.statusCode == 405 || head.statusCode == 403) {
      final get = await _client.get(uri, headers: {'Range': 'bytes=0-1'});
      return get;
    }
    return head;
  }
}
