import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BookProvider with ChangeNotifier {
  final BookService _bookService;
  List<Book> _books = [];
  List<Book> _featuredBooks = [];
  List<Book> _newReleases = [];
  List<Book> _bestsellers = [];
  bool _isLoading = false;
  String? _error;

  BookProvider({
    required BookService bookService,
  }) : _bookService = bookService {
    loadBooks();
  }

  List<Book> get books => _books;
  List<Book> get featuredBooks => _featuredBooks;
  List<Book> get newReleases => _newReleases;
  List<Book> get bestsellers => _bestsellers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBooks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _books = await _bookService.getBooks();
      _featuredBooks = await _bookService.getFeaturedBooks();
      _newReleases = await _bookService.getNewReleases();
      _bestsellers = await _bookService.getBestsellers();
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

      _books = await _bookService.searchBooks(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterBooksByCategory(String category) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _books = await _bookService.getBooksByCategory(category);
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