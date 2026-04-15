import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'opds_models.dart';

/// Minimal OPDS/Atom client (tested against Project Gutenberg).
class OpdsClient {
  OpdsClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  static final Uri defaultCatalogRoot =
      Uri.parse('https://www.gutenberg.org/ebooks/search.opds/?query=');

  Uri resolve(String href, Uri against) {
    return against.resolve(href);
  }

  Future<OpdsPage> fetchPage(Uri url) async {
    final res = await _client.get(url);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('OPDS HTTP ${res.statusCode}');
    }
    return _parseFeed(res.body, url);
  }

  /// Fetches a book detail feed and returns the first suitable EPUB acquisition URL.
  Future<String?> resolveEpubUrl(Uri detailFeedUrl) async {
    final res = await _client.get(detailFeedUrl);
    if (res.statusCode < 200 || res.statusCode >= 300) return null;
    final doc = XmlDocument.parse(res.body);
    String? best;
    for (final link in doc.descendants.whereType<XmlElement>()) {
      if (link.name.local != 'link') continue;
      final type = link.getAttribute('type') ?? '';
      final href = link.getAttribute('href');
      if (href == null) continue;
      if (!type.contains('epub')) continue;
      final rel = link.getAttribute('rel') ?? '';
      if (!rel.contains('acquisition')) continue;
      final title = link.getAttribute('title') ?? '';
      final abs = detailFeedUrl.resolve(href).toString();
      if (title.contains('EPUB3') && title.contains('no images')) {
        return abs;
      }
      best ??= abs;
    }
    return best;
  }

  OpdsPage _parseFeed(String xml, Uri documentUrl) {
    final doc = XmlDocument.parse(xml);
    final entries = <OpdsEntry>[];
    String? nextUrl;

    for (final link in doc.descendants.whereType<XmlElement>()) {
      if (link.name.local != 'link') continue;
      if (link.getAttribute('rel') == 'next') {
        final href = link.getAttribute('href');
        if (href != null) nextUrl = documentUrl.resolve(href).toString();
      }
    }

    for (final entry in doc.findAllElements('entry')) {
      final title = entry.getElement('title')?.innerText.trim() ?? '';
      if (title.isEmpty) continue;

      final content = entry.getElement('content');
      String subtitle = '';
      if (content != null) {
        subtitle = content.innerText.trim();
        final lines = subtitle.split('\n').where((s) => s.trim().isNotEmpty);
        subtitle = lines.isNotEmpty ? lines.first : '';
      }

      String? detailHref;
      String? epubHref;
      String? thumb;

      for (final link in entry.descendants.whereType<XmlElement>()) {
        if (link.name.local != 'link') continue;
        final href = link.getAttribute('href');
        if (href == null) continue;
        final type = link.getAttribute('type') ?? '';
        final rel = link.getAttribute('rel') ?? '';

        if (type.contains('thumbnail') || rel.contains('thumbnail')) {
          if (!href.startsWith('data:')) {
            thumb = documentUrl.resolve(href).toString();
          }
        }

        if (type.contains('epub+zip') && rel.contains('acquisition')) {
          epubHref = documentUrl.resolve(href).toString();
        }

        if (rel == 'subsection' && type.contains('opds')) {
          detailHref = documentUrl.resolve(href).toString();
        }
      }

      final idText = entry.getElement('id')?.innerText.trim() ?? '';
      if (detailHref == null &&
          epubHref == null &&
          idText.contains('/ebooks/') &&
          idText.endsWith('.opds')) {
        detailHref = documentUrl.resolve(idText).toString();
      }

      if (detailHref == null && epubHref == null) continue;

      entries.add(
        OpdsEntry(
          title: title,
          subtitle: subtitle,
          detailOrAcquisitionUrl: epubHref ?? detailHref!,
          thumbnailUrl: thumb,
          epubUrl: epubHref,
        ),
      );
    }

    return OpdsPage(entries: entries, nextUrl: nextUrl);
  }
}
