import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:xml/xml.dart';

/// Pulls plain text from the first substantial spine chapter for TTS.
Future<String?> extractEpubPlainTextPreview(
  String epubPath, {
  int maxChars = 12000,
}) async {
  try {
    final file = File(epubPath);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    String? readUtf8(String path) {
      final normalized = path.replaceFirst(RegExp(r'^\./'), '');
      for (final f in archive.files) {
        if (f.isFile && f.name == normalized) {
          return utf8.decode(f.content as List<int>, allowMalformed: true);
        }
      }
      for (final f in archive.files) {
        if (f.isFile && f.name.endsWith(normalized.split('/').last)) {
          return utf8.decode(f.content as List<int>, allowMalformed: true);
        }
      }
      return null;
    }

    final containerXml = readUtf8('META-INF/container.xml');
    if (containerXml == null) return null;
    var opfPath = RegExp(r'full-path="([^"]+)"')
        .firstMatch(containerXml)
        ?.group(1);
    if (opfPath == null) {
      final containerDoc = XmlDocument.parse(containerXml);
      for (final e in containerDoc.descendants.whereType<XmlElement>()) {
        if (e.name.local == 'rootfile') {
          opfPath = e.getAttribute('full-path');
          break;
        }
      }
    }
    if (opfPath == null) return null;

    final opfDir =
        opfPath.contains('/') ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1) : '';

    final opfXml = readUtf8(opfPath);
    if (opfXml == null) return null;
    final opf = XmlDocument.parse(opfXml);

    final manifest = <String, String>{};
    for (final item in opf.descendants.whereType<XmlElement>()) {
      if (item.name.local != 'item') continue;
      final id = item.getAttribute('id');
      final href = item.getAttribute('href');
      final media = item.getAttribute('media-type') ?? '';
      if (id != null && href != null) {
        if (media.contains('html') ||
            media.contains('xml') ||
            href.endsWith('.xhtml') ||
            href.endsWith('.html')) {
          manifest[id] = href;
        }
      }
    }

    final spineIds = <String>[];
    for (final itemref in opf.descendants.whereType<XmlElement>()) {
      if (itemref.name.local != 'itemref') continue;
      final idref = itemref.getAttribute('idref');
      if (idref != null) spineIds.add(idref);
    }

    final buf = StringBuffer();
    for (final id in spineIds) {
      final href = manifest[id];
      if (href == null) continue;
      final chapterPath = '$opfDir$href'.replaceAll(RegExp(r'\\'), '/');
      final raw = readUtf8(chapterPath);
      if (raw == null || raw.trim().isEmpty) continue;
      final doc = html_parser.parse(raw);
      final text = doc.body?.text ?? doc.documentElement?.text ?? '';
      final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (cleaned.length < 80) continue;
      buf.write(cleaned);
      buf.write(' ');
      if (buf.length >= maxChars) break;
    }

    if (buf.isEmpty) return null;
    var s = buf.toString();
    if (s.length > maxChars) s = s.substring(0, maxChars);
    return s;
  } catch (e, st) {
    debugPrint('epub extract: $e\n$st');
    return null;
  }
}
