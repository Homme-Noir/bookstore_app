import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistProvider with ChangeNotifier {
  List<Book> _wishlist = [];
  bool _isLoading = false;
  String? _error;

  List<Book> get wishlist => _wishlist;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load wishlist from Supabase
  Future<void> loadWishlist(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await Supabase.instance.client
          .from('wishlist')
          .select('book_id')
          .eq('user_id', userId);
      final bookIds =
          (data as List).map((e) => e['book_id'] as String).toList();
      _wishlist = bookIds
          .map((id) => Book(
              id: id,
              title: '',
              author: '',
              description: '',
              coverImage: '',
              price: 0.0,
              genres: [],
              stock: 0,
              rating: 0.0,
              reviewCount: 0,
              releaseDate: DateTime.now(),
              isBestseller: false,
              isNewArrival: false,
              isbn: '',
              pageCount: 0))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add to wishlist in Supabase
  Future<void> addToWishlist(String userId, Book book) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (!_wishlist.any((b) => b.id == book.id)) {
        await Supabase.instance.client
            .from('wishlist')
            .insert({'user_id': userId, 'book_id': book.id});
        _wishlist.add(book);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove from wishlist in Supabase
  Future<void> removeFromWishlist(String userId, String bookId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Supabase.instance.client
          .from('wishlist')
          .delete()
          .eq('user_id', userId)
          .eq('book_id', bookId);
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
