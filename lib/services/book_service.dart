import 'package:sqflite/sqflite.dart';
import 'db_helper.dart';
import '../models/book.dart';

/// A service class that manages all Firestore operations related to books.
class BookService {
  final DBHelper _dbHelper = DBHelper();

  // ---------------------------------------------------------------------------
  // READ OPERATIONS
  // ---------------------------------------------------------------------------

  /// Stream of all books in the collection.
  Stream<List<Book>> getBooksStream() {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Fetches all books once.
  Future<List<Book>> getBooks() async {
    final db = await _dbHelper.db;
    final result = await db.query('books');
    return result.map((e) => Book.fromMap(e)).toList();
  }

  /// Fetches featured books.
  Future<List<Book>> getFeaturedBooks() async {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Fetches new releases.
  Future<List<Book>> getNewReleases() async {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Fetches bestsellers.
  Future<List<Book>> getBestsellers() async {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Fetches books by category.
  Future<List<Book>> getBooksByCategory(String category) async {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Stream of bestseller books sorted by rating.
  Stream<List<Book>> getBestsellersStream() {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Stream of new arrivals sorted by release date.
  Stream<List<Book>> getNewArrivalsStream() {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Returns a filtered stream of books based on category and sort option.
  Stream<List<Book>> getBooksFiltered({
    String? category,
    String sort = 'Newest',
    int pageSize = 10,
  }) {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Stream of filtered bestseller books.
  Stream<List<Book>> getBestsellersFiltered({
    String? category,
    String sort = 'Newest',
    int pageSize = 10,
  }) {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Stream of filtered new arrival books.
  Stream<List<Book>> getNewArrivalsFiltered({
    String? category,
    String sort = 'Newest',
    int pageSize = 10,
  }) {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Stream of books by genre.
  Stream<List<Book>> getBooksByGenre(String genre) {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Stream of books by author.
  Stream<List<Book>> getBooksByAuthor(String author) {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Stream search for books by title.
  Stream<List<Book>> searchBooksStream(String query) {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// One-time search for books by title.
  Future<List<Book>> searchBooks(String query) async {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Fetch a single book by its ID.
  Future<Book?> getBook(String id) async {
    final db = await _dbHelper.db;
    final result = await db.query('books', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Book.fromMap(result.first);
    }
    return null;
  }

  /// Fetch all book categories.
  Future<List<String>> getCategories() async {
    final db = await _dbHelper.db;
    final result = await db.query('books', columns: ['genres']);
    final genres = result
        .expand((row) => (row['genres'] as String).split(','))
        .toSet()
        .toList();
    return genres;
  }

  // ---------------------------------------------------------------------------
  // WRITE OPERATIONS
  // ---------------------------------------------------------------------------

  /// Add a new book to Firestore.
  Future<void> addBook(Book book) async {
    final db = await _dbHelper.db;
    await db.insert('books', book.toMap());
  }

  /// Update an existing book in Firestore.
  Future<void> updateBook(Book book) async {
    final db = await _dbHelper.db;
    await db
        .update('books', book.toMap(), where: 'id = ?', whereArgs: [book.id]);
  }

  /// Delete a book from Firestore.
  Future<void> deleteBook(String id) async {
    final db = await _dbHelper.db;
    await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  /// Adds a new category.
  Future<void> addCategory(String category) async {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Updates an existing category.
  Future<void> updateCategory(String oldCategory, String newCategory) async {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  /// Deletes a category.
  Future<void> deleteCategory(String category) async {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }

  // ---------------------------------------------------------------------------
  // UTILITY
  // ---------------------------------------------------------------------------

  /// Applies a sort option to a Firestore query.
  Query _applySorting(Query query, String sort) {
    // This method is not available in the new implementation
    throw UnimplementedError();
  }
}
