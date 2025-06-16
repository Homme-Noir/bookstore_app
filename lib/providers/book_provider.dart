import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../models/book.dart';

class BookProvider with ChangeNotifier {
  final BookService _bookService = BookService();
  List<Book> _books = [];
  List<Book> _searchResults = [];
  Book? _selectedBook;
  bool _isLoading = false;
  String? _error;

  List<Book> get books => _books;
  List<Book> get searchResults => _searchResults;
  Book? get selectedBook => _selectedBook;
  bool get isLoading => _isLoading;
  String? get error => _error;

  BookProvider() {
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _books = await _bookService.getBooks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchBooks(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _searchResults = await _bookService.searchBooks(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectBook(String bookId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _selectedBook = await _bookService.getBook(bookId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBook(Book book) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _bookService.addBook(book);
      await _loadBooks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _bookService.updateBook(book);
      await _loadBooks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _bookService.deleteBook(bookId);
      await _loadBooks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 