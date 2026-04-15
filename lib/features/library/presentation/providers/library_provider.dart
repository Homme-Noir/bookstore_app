import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../data/local_library_repository.dart';
import '../../domain/models/library_item.dart';

class LibraryProvider extends ChangeNotifier {
  LibraryProvider({required LocalLibraryRepository repository})
      : _repository = repository;

  final LocalLibraryRepository _repository;
  final Random _random = Random();

  List<LibraryItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<LibraryItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<LibraryItem> get currentlyReading =>
      _items.where((item) => item.progress > 0 && !item.isFinished).toList();

  List<LibraryItem> get finished =>
      _items.where((item) => item.isFinished || item.progress >= 1).toList();

  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repository.getItems();
    } catch (e) {
      _error = 'Failed to load library';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> importBook() async {
    try {
      _error = null;
      notifyListeners();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['epub', 'pdf'],
        allowMultiple: false,
      );

      final selected = result?.files.single;
      if (selected == null || selected.path == null) {
        return;
      }

      final path = selected.path!;
      await addImportedFile(path: path);
    } catch (e) {
      _error = 'Import failed';
      notifyListeners();
    }
  }

  Future<void> addImportedFile({
    required String path,
    String? title,
    String author = 'Unknown Author',
    String? sourceUrl,
    String? checksum,
  }) async {
    final resolvedTitle = title ?? p.basenameWithoutExtension(path);
    final extension = p.extension(path).replaceFirst('.', '').toLowerCase();
    final item = LibraryItem(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}',
      title: resolvedTitle,
      author: author,
      filePath: path,
      format: extension,
      sourceUrl: sourceUrl,
      checksum: checksum,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _items = [item, ..._items];
    await _repository.saveItems(_items);
    notifyListeners();
  }

  Future<void> updateProgress(String itemId, double progress) async {
    _items = _items.map((item) {
      if (item.id != itemId) {
        return item;
      }
      final clamped = progress.clamp(0, 1).toDouble();
      return item.copyWith(
        progress: clamped,
        isFinished: clamped >= 0.99,
        updatedAt: DateTime.now(),
      );
    }).toList();
    await _repository.saveItems(_items);
    notifyListeners();
  }

  Future<void> replaceFromSync(List<LibraryItem> syncedItems) async {
    _items = [...syncedItems]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _repository.saveItems(_items);
    notifyListeners();
  }
}
