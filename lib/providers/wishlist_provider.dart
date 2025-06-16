import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/wishlist_service.dart';

class WishlistProvider with ChangeNotifier {
  final WishlistService _wishlistService = WishlistService();
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

      _wishlist = await _wishlistService.getWishlist(userId);
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

      await _wishlistService.addToWishlist(userId, book.id);
      _wishlist.add(book);
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

      await _wishlistService.removeFromWishlist(userId, bookId);
      _wishlist.removeWhere((book) => book.id == bookId);
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
}
