import '../../../core/storage/local_database.dart';

import '../domain/models/library_item.dart';

class LocalLibraryRepository {
  LocalLibraryRepository({required LocalDatabase database}) : _database = database;

  final LocalDatabase _database;

  Future<List<LibraryItem>> getItems() => _database.listLibraryItems();

  Future<void> saveItems(List<LibraryItem> items) =>
      _database.saveLibraryItems(items);
}
