import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

/// A service class that manages all Firestore operations related to books.
class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'books';

  // ---------------------------------------------------------------------------
  // READ OPERATIONS
  // ---------------------------------------------------------------------------

  /// Stream of all books in the collection.
  Stream<List<Book>> getBooksStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Book.fromFirestore).toList());
  }

  /// Fetches all books once.
  Future<List<Book>> getBooks() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map(Book.fromFirestore).toList();
  }

  /// Stream of bestseller books sorted by rating.
  Stream<List<Book>> getBestsellers() {
    return _firestore
        .collection(_collection)
        .where('isBestseller', isEqualTo: true)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Book.fromFirestore).toList());
  }

  /// Stream of new arrivals sorted by release date.
  Stream<List<Book>> getNewArrivals() {
    return _firestore
        .collection(_collection)
        .where('isNewArrival', isEqualTo: true)
        .orderBy('releaseDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Book.fromFirestore).toList());
  }

  /// Returns a filtered stream of books based on category and sort option.
  Stream<List<Book>> getBooksFiltered({
    String? category,
    String sort = 'Newest',
    int pageSize = 10,
  }) {
    Query query = _firestore.collection(_collection);

    if (category != null && category.isNotEmpty) {
      query = query.where('genres', arrayContains: category);
    }

    query = _applySorting(query, sort).limit(pageSize);

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map(Book.fromFirestore).toList(),
    );
  }

  /// Stream of filtered bestseller books.
  Stream<List<Book>> getBestsellersFiltered({
    String? category,
    String sort = 'Newest',
    int pageSize = 10,
  }) {
    Query query = _firestore
        .collection(_collection)
        .where('isBestseller', isEqualTo: true);

    if (category != null && category.isNotEmpty) {
      query = query.where('genres', arrayContains: category);
    }

    query = _applySorting(query, sort).limit(pageSize);

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map(Book.fromFirestore).toList(),
    );
  }

  /// Stream of filtered new arrival books.
  Stream<List<Book>> getNewArrivalsFiltered({
    String? category,
    String sort = 'Newest',
    int pageSize = 10,
  }) {
    Query query = _firestore
        .collection(_collection)
        .where('isNewArrival', isEqualTo: true);

    if (category != null && category.isNotEmpty) {
      query = query.where('genres', arrayContains: category);
    }

    query = _applySorting(query, sort).limit(pageSize);

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map(Book.fromFirestore).toList(),
    );
  }

  /// Stream of books by genre.
  Stream<List<Book>> getBooksByGenre(String genre) {
    return _firestore
        .collection(_collection)
        .where('genres', arrayContains: genre)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Book.fromFirestore).toList());
  }

  /// Stream of books by author.
  Stream<List<Book>> getBooksByAuthor(String author) {
    return _firestore
        .collection(_collection)
        .where('author', isEqualTo: author)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Book.fromFirestore).toList());
  }

  /// Stream search for books by title.
  Stream<List<Book>> searchBooksStream(String query) {
    return _firestore
        .collection(_collection)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Book.fromFirestore).toList());
  }

  /// One-time search for books by title.
  Future<List<Book>> searchBooks(String query) async {
    final snapshot =
        await _firestore
            .collection(_collection)
            .where('title', isGreaterThanOrEqualTo: query)
            .where('title', isLessThanOrEqualTo: '$query\uf8ff')
            .get();
    return snapshot.docs.map(Book.fromFirestore).toList();
  }

  /// Fetch a single book by its ID.
  Future<Book> getBook(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    return Book.fromFirestore(doc);
  }

  /// Fetch all book categories.
  Future<List<String>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  // ---------------------------------------------------------------------------
  // WRITE OPERATIONS
  // ---------------------------------------------------------------------------

  /// Add a new book to Firestore.
  Future<void> addBook(Book book) async {
    try {
      await _firestore.collection(_collection).doc(book.id).set(book.toMap());
    } catch (e) {
      print('Error adding book: $e');
      rethrow;
    }
  }

  /// Update an existing book in Firestore.
  Future<void> updateBook(Book book) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(book.id)
          .update(book.toMap());
    } catch (e) {
      print('Error updating book: $e');
      rethrow;
    }
  }

  /// Delete a book from Firestore.
  Future<void> deleteBook(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      print('Error deleting book: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UTILITY
  // ---------------------------------------------------------------------------

  /// Applies a sort option to a Firestore query.
  Query _applySorting(Query query, String sort) {
    switch (sort) {
      case 'Price: Low to High':
        return query.orderBy('price');
      case 'Price: High to Low':
        return query.orderBy('price', descending: true);
      case 'Rating':
        return query.orderBy('rating', descending: true);
      case 'Newest':
      default:
        return query.orderBy('releaseDate', descending: true);
    }
  }
}
