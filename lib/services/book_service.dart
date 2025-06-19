import '../mock_data.dart';
import '../models/book.dart';

/// A service class that manages all Firestore operations related to books.
class BookService {
  static final List<String> _mockCategories = [
    'Fiction',
    'Classic',
    'Fantasy',
    'Romance',
    'Adventure'
  ];

  List<Book> getBooks() {
    return MockData.books;
  }

  Stream<List<Book>> getBooksStream() async* {
    yield MockData.books;
  }

  Future<void> addBook(Book book) async {
    MockData.books.add(book);
  }

  Future<void> updateBook(Book book) async {
    final idx = MockData.books.indexWhere((b) => b.id == book.id);
    if (idx != -1) {
      MockData.books[idx] = book;
    }
  }

  Future<void> deleteBook(String id) async {
    MockData.books.removeWhere((b) => b.id == id);
  }

  Future<List<String>> getCategories() async {
    return _mockCategories;
  }

  Future<void> addCategory(String category) async {
    if (!_mockCategories.contains(category)) {
      _mockCategories.add(category);
    }
  }

  Future<void> updateCategory(String oldCategory, String newCategory) async {
    final idx = _mockCategories.indexOf(oldCategory);
    if (idx != -1) {
      _mockCategories[idx] = newCategory;
    }
  }

  Future<void> deleteCategory(String category) async {
    _mockCategories.remove(category);
  }

  Future<Book?> getBook(String id) async {
    for (final b in MockData.books) {
      if (b.id == id) return b;
    }
    return null;
  }

  // Add more mock methods as needed.
}
