import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BookProvider with ChangeNotifier {
  final BookService _bookService;
  List<Book> _books = [];
  bool _isLoading = false;
  String? _error;

  BookProvider({
    required BookService bookService,
  }) : _bookService = bookService {
    loadBooks();
  }

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadBooks() {
    _isLoading = true;
    _error = null;
    notifyListeners();
    _books = _bookService.getBooks();
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
