import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/book.dart';

class FavouritesProvider with ChangeNotifier {
  List<Book> _favourites = [];
  bool _isLoading = false;
  String? _error;

  List<Book> get favourites => _favourites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load favourites
  Future<void> loadFavourites(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _loadFavouritesFromStorage(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add to favourites
  Future<void> addToFavourites(String userId, Book book) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (!_favourites.any((b) => b.id == book.id)) {
        _favourites.add(book);
        await _saveFavouritesToStorage(userId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove from favourites
  Future<void> removeFromFavourites(String userId, String bookId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _favourites.removeWhere((book) => book.id == bookId);
      await _saveFavouritesToStorage(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if book is in favourites
  bool isInFavourites(String bookId) {
    return _favourites.any((book) => book.id == bookId);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Save favourites to local storage
  Future<void> _saveFavouritesToStorage(String userId) async {
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
      await prefs.setString('favourites_$userId', jsonEncode(favouritesJson));
    } catch (e) {
      debugPrint('Error saving favourites: $e');
    }
  }

  // Load favourites from local storage
  Future<void> _loadFavouritesFromStorage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favouritesString = prefs.getString('favourites_$userId');

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
