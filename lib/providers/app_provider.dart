import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/open_library_service.dart';
import '../models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

/// A provider class that manages the application state and services.
class AppProvider extends ChangeNotifier {
  /// The authentication service for user management.
  final AuthService _authService;

  /// The Open Library service for fetching book data.
  final OpenLibraryService _openLibraryService;

  /// The current user of the application.
  String? _userId;

  /// The list of books from Open Library.
  List<Book> _books = [];

  /// The list of books purchased by the user.
  List<Book> _purchasedBooks = [];

  /// The list of books in user's wishlist.
  List<Book> _wishlist = [];

  /// The list of books in user's favorites.
  List<Book> _favourites = [];

  /// Books organized by categories
  final Map<String, List<Book>> _booksByCategory = {};

  /// The current theme mode of the application.
  ThemeMode _themeMode = ThemeMode.system;

  /// Loading state for books
  bool _isLoadingBooks = false;
  String? _booksError;

  /// Returns whether the provider is currently loading books.
  bool get isLoadingBooks => _isLoadingBooks;

  /// Returns the current error message for books.
  String? get booksError => _booksError;

  /// Returns the current theme mode.
  ThemeMode get themeMode => _themeMode;

  /// Returns whether the user is authenticated.
  bool get isAuthenticated => _userId != null;

  /// Returns books organized by category
  Map<String, List<Book>> get booksByCategory => _booksByCategory;

  /// Returns the list of books in wishlist
  List<Book> get wishlist => _wishlist;

  /// Returns the list of books in favourites
  List<Book> get favourites => _favourites;

  /// Creates a new instance of AppProvider.
  AppProvider({
    required AuthService authService,
    required OpenLibraryService openLibraryService,
  })  : _authService = authService,
        _openLibraryService = openLibraryService {
    _init();
  }

  /// Sets the theme mode of the application.
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Initializes the provider by setting up listeners for user changes and loading initial data.
  Future<void> _init() async {
    _authService.onAuthStateChanged.listen((user) {
      _userId = user?['uid'];
      if (_userId != null) {
        _loadUserData();
      } else {
        _clearUserData();
      }
      notifyListeners();
    });

    await _loadBooksByCategory();
  }

  /// Loads user-specific data such as purchased books, wishlist, and favourites.
  Future<void> _loadUserData() async {
    if (_userId == null) return;

    await Future.wait([
      loadPurchasedBooks(),
      loadWishlist(),
      loadFavourites(),
    ]);
    notifyListeners();
  }

  /// Clears user-specific data when the user logs out.
  void _clearUserData() {
    _purchasedBooks = [];
    _wishlist = [];
    _favourites = [];
    notifyListeners();
  }

  /// Loads books organized by categories
  Future<void> _loadBooksByCategory() async {
    try {
      _isLoadingBooks = true;
      _booksError = null;
      notifyListeners();

      final categories = [
        'Action',
        'Romance',
        'Mystery',
        'Science Fiction',
        'Fantasy',
        'Biography',
        'History',
        'Self-Help',
        'Business',
        'Cooking',
      ];

      _booksByCategory.clear();

      for (final category in categories) {
        try {
          final books = await _openLibraryService.getBooksForCategory(category);
          // Set price and random rating for all books
          final random = Random();
          final processedBooks = books.map((book) {
            return Book(
              id: book.id,
              title: book.title,
              author: book.author,
              description: book.description,
              coverImage: book.coverImage,
              price: 5.0,
              genres: book.genres,
              stock: book.stock,
              rating: 3.0 + random.nextDouble() * 2.0, // 3.0 to 5.0
              reviewCount: book.reviewCount,
              releaseDate: book.releaseDate,
              isBestseller: book.isBestseller,
              isNewArrival: book.isNewArrival,
              isbn: book.isbn,
              pageCount: book.pageCount,
              status: book.status,
              authors: book.authors,
              categories: book.categories,
            );
          }).toList();

          _booksByCategory[category] = processedBooks;
        } catch (e) {
          debugPrint('Error loading books for category $category: $e');
          _booksByCategory[category] = [];
        }
      }

      // Also load general books for the main store
      _books = await _openLibraryService.getDefaultBooks();
      final random = Random();
      _books = _books.map((book) {
        return Book(
          id: book.id,
          title: book.title,
          author: book.author,
          description: book.description,
          coverImage: book.coverImage,
          price: 5.0,
          genres: book.genres,
          stock: book.stock,
          rating: 3.0 + random.nextDouble() * 2.0, // 3.0 to 5.0
          reviewCount: book.reviewCount,
          releaseDate: book.releaseDate,
          isBestseller: book.isBestseller,
          isNewArrival: book.isNewArrival,
          isbn: book.isbn,
          pageCount: book.pageCount,
          status: book.status,
          authors: book.authors,
          categories: book.categories,
        );
      }).toList();
    } catch (e) {
      _booksError = e.toString();
    } finally {
      _isLoadingBooks = false;
      notifyListeners();
    }
  }

  /// Public method to load books from Open Library.
  Future<void> loadBooks() async {
    await _loadBooksByCategory();
  }

  /// Returns the current user.
  String? get userId => _userId;

  /// Returns the list of books.
  List<Book> get books => _books;

  /// Returns the list of books purchased by the user.
  List<Book> get purchasedBooks => _purchasedBooks;

  /// Signs in a user with the provided email and password.
  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
  }

  /// Signs up a new user with the provided email and password.
  Future<void> signUp(String email, String password) async {
    await _authService.signUp(email, password);
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Resets the password for a user with the provided email.
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  /// Searches for books using Open Library API.
  Future<void> searchBooks(String query) async {
    try {
      _isLoadingBooks = true;
      _booksError = null;
      notifyListeners();

      if (query.trim().isEmpty) {
        _books = await _openLibraryService.getDefaultBooks();
      } else {
        _books = await _openLibraryService.searchBooks(query);
      }
      // Set price and random rating for all books
      final random = Random();
      _books = _books.map((book) {
        return Book(
          id: book.id,
          title: book.title,
          author: book.author,
          description: book.description,
          coverImage: book.coverImage,
          price: 5.0,
          genres: book.genres,
          stock: book.stock,
          rating: 3.0 + random.nextDouble() * 2.0, // 3.0 to 5.0
          reviewCount: book.reviewCount,
          releaseDate: book.releaseDate,
          isBestseller: book.isBestseller,
          isNewArrival: book.isNewArrival,
          isbn: book.isbn,
          pageCount: book.pageCount,
          status: book.status,
          authors: book.authors,
          categories: book.categories,
        );
      }).toList();
    } catch (e) {
      _booksError = e.toString();
    } finally {
      _isLoadingBooks = false;
      notifyListeners();
    }
  }

  /// Adds a book to the user's purchased books.
  Future<void> addPurchasedBook(Book book) async {
    if (_userId == null) return;

    // Check if book is already purchased
    if (_purchasedBooks.any((b) => b.id == book.id)) {
      return; // Already purchased
    }

    _purchasedBooks.add(book);
    notifyListeners();

    // Save to persistent storage (local storage)
    await _savePurchasedBooks();
  }

  /// Checks if a book is purchased by the user.
  bool isBookPurchased(String bookId) {
    return _purchasedBooks.any((book) => book.id == bookId);
  }

  /// Gets the list of purchased books.
  List<Book> getPurchasedBooks() {
    return _purchasedBooks;
  }

  /// Loads purchased books for the user.
  Future<void> loadPurchasedBooks() async {
    if (_userId == null) return;

    await _loadPurchasedBooks();
    notifyListeners();
  }

  /// Adds a book to the user's wishlist.
  Future<void> addToWishlist(Book book) async {
    if (_userId == null) return;

    if (!_wishlist.any((b) => b.id == book.id)) {
      _wishlist.add(book);
      notifyListeners();
      await _saveWishlist();
    }
  }

  /// Removes a book from the user's wishlist.
  Future<void> removeFromWishlist(String bookId) async {
    if (_userId == null) return;

    _wishlist.removeWhere((book) => book.id == bookId);
    notifyListeners();
    await _saveWishlist();
  }

  /// Checks if a book is in the user's wishlist.
  bool isInWishlist(String bookId) {
    return _wishlist.any((book) => book.id == bookId);
  }

  /// Loads wishlist for the user.
  Future<void> loadWishlist() async {
    if (_userId == null) return;

    await _loadWishlist();
    notifyListeners();
  }

  /// Adds a book to the user's favourites.
  Future<void> addToFavourites(Book book) async {
    if (_userId == null) return;

    if (!_favourites.any((b) => b.id == book.id)) {
      _favourites.add(book);
      notifyListeners();
      await _saveFavourites();
    }
  }

  /// Removes a book from the user's favourites.
  Future<void> removeFromFavourites(String bookId) async {
    if (_userId == null) return;

    _favourites.removeWhere((book) => book.id == bookId);
    notifyListeners();
    await _saveFavourites();
  }

  /// Checks if a book is in the user's favourites.
  bool isInFavourites(String bookId) {
    return _favourites.any((book) => book.id == bookId);
  }

  /// Loads favourites for the user.
  Future<void> loadFavourites() async {
    if (_userId == null) return;

    await _loadFavourites();
    notifyListeners();
  }

  /// Saves purchased books to local storage.
  Future<void> _savePurchasedBooks() async {
    if (_userId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final purchasedBooksJson = _purchasedBooks
          .map((book) => {
                'id': book.id,
                'title': book.title,
                'author': book.author,
                'description': book.description,
                'coverImage': book.coverImage,
                'price': book.price,
                'genres': book.genres,
                'stock': book.stock,
                'rating': book.rating,
                'reviewCount': book.reviewCount,
                'releaseDate': book.releaseDate.toIso8601String(),
                'isBestseller': book.isBestseller,
                'isNewArrival': book.isNewArrival,
                'isbn': book.isbn,
                'pageCount': book.pageCount,
                'status': book.status,
              })
          .toList();

      await prefs.setString(
          'purchased_books_$_userId', jsonEncode(purchasedBooksJson));
    } catch (e) {
      debugPrint('Error saving purchased books: $e');
    }
  }

  /// Loads purchased books from local storage.
  Future<void> _loadPurchasedBooks() async {
    if (_userId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final purchasedBooksString = prefs.getString('purchased_books_$_userId');

      if (purchasedBooksString != null) {
        final purchasedBooksJson = jsonDecode(purchasedBooksString) as List;
        _purchasedBooks = purchasedBooksJson
            .map((bookJson) => Book(
                  id: bookJson['id'],
                  title: bookJson['title'],
                  author: bookJson['author'],
                  description: bookJson['description'],
                  coverImage: bookJson['coverImage'],
                  price: bookJson['price'].toDouble(),
                  genres: List<String>.from(bookJson['genres']),
                  stock: bookJson['stock'],
                  rating: bookJson['rating'].toDouble(),
                  reviewCount: bookJson['reviewCount'],
                  releaseDate: DateTime.parse(bookJson['releaseDate']),
                  isBestseller: bookJson['isBestseller'],
                  isNewArrival: bookJson['isNewArrival'],
                  isbn: bookJson['isbn'],
                  pageCount: bookJson['pageCount'],
                  status: bookJson['status'],
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading purchased books: $e');
      _purchasedBooks = [];
    }
  }

  /// Saves wishlist to local storage.
  Future<void> _saveWishlist() async {
    if (_userId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = _wishlist
          .map((book) => {
                'id': book.id,
                'title': book.title,
                'author': book.author,
                'description': book.description,
                'coverImage': book.coverImage,
                'price': book.price,
                'genres': book.genres,
                'stock': book.stock,
                'rating': book.rating,
                'reviewCount': book.reviewCount,
                'releaseDate': book.releaseDate.toIso8601String(),
                'isBestseller': book.isBestseller,
                'isNewArrival': book.isNewArrival,
                'isbn': book.isbn,
                'pageCount': book.pageCount,
                'status': book.status,
              })
          .toList();

      await prefs.setString('wishlist_$_userId', jsonEncode(wishlistJson));
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }

  /// Loads wishlist from local storage.
  Future<void> _loadWishlist() async {
    if (_userId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistString = prefs.getString('wishlist_$_userId');

      if (wishlistString != null) {
        final wishlistJson = jsonDecode(wishlistString) as List;
        _wishlist = wishlistJson
            .map((bookJson) => Book(
                  id: bookJson['id'],
                  title: bookJson['title'],
                  author: bookJson['author'],
                  description: bookJson['description'],
                  coverImage: bookJson['coverImage'],
                  price: bookJson['price'].toDouble(),
                  genres: List<String>.from(bookJson['genres']),
                  stock: bookJson['stock'],
                  rating: bookJson['rating'].toDouble(),
                  reviewCount: bookJson['reviewCount'],
                  releaseDate: DateTime.parse(bookJson['releaseDate']),
                  isBestseller: bookJson['isBestseller'],
                  isNewArrival: bookJson['isNewArrival'],
                  isbn: bookJson['isbn'],
                  pageCount: bookJson['pageCount'],
                  status: bookJson['status'],
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
      _wishlist = [];
    }
  }

  /// Saves favourites to local storage.
  Future<void> _saveFavourites() async {
    if (_userId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final favouritesJson = _favourites
          .map((book) => {
                'id': book.id,
                'title': book.title,
                'author': book.author,
                'description': book.description,
                'coverImage': book.coverImage,
                'price': book.price,
                'genres': book.genres,
                'stock': book.stock,
                'rating': book.rating,
                'reviewCount': book.reviewCount,
                'releaseDate': book.releaseDate.toIso8601String(),
                'isBestseller': book.isBestseller,
                'isNewArrival': book.isNewArrival,
                'isbn': book.isbn,
                'pageCount': book.pageCount,
                'status': book.status,
              })
          .toList();

      await prefs.setString('favourites_$_userId', jsonEncode(favouritesJson));
    } catch (e) {
      debugPrint('Error saving favourites: $e');
    }
  }

  /// Loads favourites from local storage.
  Future<void> _loadFavourites() async {
    if (_userId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final favouritesString = prefs.getString('favourites_$_userId');

      if (favouritesString != null) {
        final favouritesJson = jsonDecode(favouritesString) as List;
        _favourites = favouritesJson
            .map((bookJson) => Book(
                  id: bookJson['id'],
                  title: bookJson['title'],
                  author: bookJson['author'],
                  description: bookJson['description'],
                  coverImage: bookJson['coverImage'],
                  price: bookJson['price'].toDouble(),
                  genres: List<String>.from(bookJson['genres']),
                  stock: bookJson['stock'],
                  rating: bookJson['rating'].toDouble(),
                  reviewCount: bookJson['reviewCount'],
                  releaseDate: DateTime.parse(bookJson['releaseDate']),
                  isBestseller: bookJson['isBestseller'],
                  isNewArrival: bookJson['isNewArrival'],
                  isbn: bookJson['isbn'],
                  pageCount: bookJson['pageCount'],
                  status: bookJson['status'],
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading favourites: $e');
      _favourites = [];
    }
  }
}
