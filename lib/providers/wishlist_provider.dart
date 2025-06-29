import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/book.dart';

class WishlistProvider with ChangeNotifier {
  List<Book> _wishlist = [];
  bool _isLoading = false;
  String? _error;

  List<Book> get wishlist => _wishlist;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load wishlist
  Future<void> loadWishlist(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _loadWishlistFromStorage(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add to wishlist
  Future<void> addToWishlist(String userId, Book book) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (!_wishlist.any((b) => b.id == book.id)) {
        _wishlist.add(book);
        await _saveWishlistToStorage(userId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove from wishlist
  Future<void> removeFromWishlist(String userId, String bookId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _wishlist.removeWhere((book) => book.id == bookId);
      await _saveWishlistToStorage(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if book is in wishlist
  bool isInWishlist(String bookId) {
    return _wishlist.any((book) => book.id == bookId);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Save wishlist to local storage
  Future<void> _saveWishlistToStorage(String userId) async {
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
      await prefs.setString('wishlist_$userId', jsonEncode(wishlistJson));
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }

  // Load wishlist from local storage
  Future<void> _loadWishlistFromStorage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistString = prefs.getString('wishlist_$userId');

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
}
