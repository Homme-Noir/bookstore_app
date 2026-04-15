import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../library/domain/models/library_item.dart';
import '../../data/local_reader_repository.dart';
import '../../domain/bookmark_marker.dart';
import '../../domain/models/reader_annotation.dart';
import '../../domain/models/reading_progress.dart';

/// Page background for EPUB/PDF chrome (Readest-style day / sepia / night).
enum ReaderPaperTheme {
  light,
  sepia,
  dark;

  static ReaderPaperTheme fromName(String? name) {
    return ReaderPaperTheme.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ReaderPaperTheme.light,
    );
  }
}

class ReaderProvider extends ChangeNotifier {
  ReaderProvider({required LocalReaderRepository repository})
      : _repository = repository;

  final LocalReaderRepository _repository;

  final Map<String, ReadingProgress> _progressByItem = {};
  final Map<String, List<ReaderAnnotation>> _annotationsByItem = {};
  ReaderPaperTheme _paperTheme = ReaderPaperTheme.light;
  double _fontScale = 1;

  Map<String, ReadingProgress> get progressByItem => _progressByItem;
  Map<String, List<ReaderAnnotation>> get annotationsByItem => _annotationsByItem;
  ReaderPaperTheme get paperTheme => _paperTheme;
  /// Kept for callers that still check “sepia”; true when [paperTheme] is sepia.
  bool get sepiaMode => _paperTheme == ReaderPaperTheme.sepia;
  double get fontScale => _fontScale;

  Color get readerBackgroundColor => switch (_paperTheme) {
        ReaderPaperTheme.light => Colors.white,
        ReaderPaperTheme.sepia => const Color(0xFFF4ECD8),
        ReaderPaperTheme.dark => const Color(0xFF1C1917),
      };

  Color get readerForegroundColor => switch (_paperTheme) {
        ReaderPaperTheme.dark => const Color(0xFFE7E5E4),
        _ => const Color(0xFF292524),
      };

  Future<void> load() async {
    _progressByItem
      ..clear()
      ..addAll(await _repository.loadProgress());
    _annotationsByItem
      ..clear()
      ..addAll(await _repository.loadAnnotations());
    final prefs = await SharedPreferences.getInstance();
    _paperTheme = ReaderPaperTheme.fromName(prefs.getString('reader_pref_paper'));
    if (prefs.containsKey('reader_pref_sepia_mode') &&
        prefs.getBool('reader_pref_sepia_mode') == true &&
        !prefs.containsKey('reader_pref_paper')) {
      _paperTheme = ReaderPaperTheme.sepia;
    }
    _fontScale = prefs.getDouble('reader_pref_font_scale') ?? 1;
    notifyListeners();
  }

  ReadingProgress? progressFor(String itemId) => _progressByItem[itemId];

  List<ReaderAnnotation> annotationsFor(String itemId) =>
      (_annotationsByItem[itemId] ?? const [])
          .where((entry) => !entry.isDeleted)
          .toList();

  List<ReadingProgress> get allProgress => _progressByItem.values.toList();
  List<ReaderAnnotation> get allAnnotations =>
      _annotationsByItem.values.expand((list) => list).toList();

  Future<void> saveProgress({
    required String itemId,
    required double percentage,
    required int position,
  }) async {
    _progressByItem[itemId] = ReadingProgress(
      itemId: itemId,
      percentage: percentage.clamp(0, 1),
      position: position,
      updatedAt: DateTime.now(),
    );
    await _repository.saveProgress(_progressByItem[itemId]!);
    notifyListeners();
  }

  Future<void> addAnnotation({
    required String itemId,
    required String note,
    required int start,
    required int end,
  }) async {
    final annotationId = 'a_${DateTime.now().millisecondsSinceEpoch}';
    final annotation = ReaderAnnotation(
      id: annotationId,
      itemId: itemId,
      annotationId: annotationId,
      note: note,
      start: start,
      end: end,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      version: 1,
    );
    final List<ReaderAnnotation> current = [
      ...(_annotationsByItem[itemId] ?? const <ReaderAnnotation>[]),
    ];
    current.add(annotation);
    _annotationsByItem[itemId] = current;
    await _repository.addAnnotation(annotation);
    notifyListeners();
  }

  Future<void> deleteAnnotation({
    required String itemId,
    required String annotationId,
  }) async {
    final bucket = _annotationsByItem[itemId];
    if (bucket == null) return;
    final index = bucket.indexWhere((entry) => entry.annotationId == annotationId);
    if (index == -1) return;
    final existing = bucket[index];
    final tombstone = existing.copyWith(
      isDeleted: true,
      version: existing.version + 1,
      updatedAt: DateTime.now(),
    );
    bucket[index] = tombstone;
    _annotationsByItem[itemId] = bucket;
    await _repository.addAnnotation(tombstone);
    notifyListeners();
  }

  Future<void> restoreAnnotation({
    required String itemId,
    required String annotationId,
  }) async {
    final bucket = _annotationsByItem[itemId];
    if (bucket == null) return;
    final index = bucket.indexWhere((entry) => entry.annotationId == annotationId);
    if (index == -1) return;
    final existing = bucket[index];
    final restored = existing.copyWith(
      isDeleted: false,
      version: existing.version + 1,
      updatedAt: DateTime.now(),
    );
    bucket[index] = restored;
    _annotationsByItem[itemId] = bucket;
    await _repository.addAnnotation(restored);
    notifyListeners();
  }

  Future<void> hardDeleteAnnotation({
    required String itemId,
    required String annotationId,
  }) async {
    final bucket = _annotationsByItem[itemId];
    if (bucket == null) return;
    final index = bucket.indexWhere((entry) => entry.annotationId == annotationId);
    if (index == -1) return;
    final existing = bucket[index];
    final tombstone = existing.copyWith(
      note: '',
      isDeleted: true,
      version: existing.version + 1,
      updatedAt: DateTime.now(),
    );
    bucket[index] = tombstone;
    _annotationsByItem[itemId] = bucket;
    await _repository.addAnnotation(tombstone);
    notifyListeners();
  }

  Future<void> setReaderPreferences({
    bool? sepiaMode,
    ReaderPaperTheme? paperTheme,
    double? fontScale,
  }) async {
    if (paperTheme != null) {
      _paperTheme = paperTheme;
    } else if (sepiaMode != null) {
      _paperTheme = sepiaMode ? ReaderPaperTheme.sepia : ReaderPaperTheme.light;
    }
    if (fontScale != null) {
      _fontScale = fontScale.clamp(0.8, 1.4);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reader_pref_paper', _paperTheme.name);
    await prefs.setBool('reader_pref_sepia_mode', _paperTheme == ReaderPaperTheme.sepia);
    await prefs.setDouble('reader_pref_font_scale', _fontScale);
    notifyListeners();
  }

  Future<void> applySyncedProgress(List<ReadingProgress> items) async {
    for (final item in items) {
      _progressByItem[item.itemId] = item;
      await _repository.saveProgress(item);
    }
    notifyListeners();
  }

  Future<void> addBookmarkAt({
    required String itemId,
    required int position,
  }) {
    return addAnnotation(
      itemId: itemId,
      note: kBookmarkMarker,
      start: position,
      end: position + 1,
    );
  }

  String exportAnnotationsAsText(LibraryItem book) {
    final buf = StringBuffer()
      ..writeln('# ${book.title}')
      ..writeln('Author: ${book.author}')
      ..writeln();
    for (final a in annotationsFor(book.id)) {
      if (isBookmarkNote(a.note)) {
        buf.writeln('[Bookmark] position ${a.start}');
      } else {
        buf.writeln('- ${a.note} (position ${a.start})');
      }
    }
    return buf.toString();
  }

  Future<void> applySyncedAnnotations(List<ReaderAnnotation> items) async {
    for (final item in items) {
      final bucket = _annotationsByItem[item.itemId] ?? <ReaderAnnotation>[];
      final index = bucket.indexWhere((entry) => entry.annotationId == item.annotationId);
      if (index == -1) {
        bucket.add(item);
      } else {
        final existing = bucket[index];
        if (item.updatedAt.isAfter(existing.updatedAt)) {
          bucket[index] = item;
        }
      }
      _annotationsByItem[item.itemId] = bucket;
      await _repository.addAnnotation(item);
    }
    notifyListeners();
  }
}
