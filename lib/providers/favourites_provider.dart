import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavouritesProvider with ChangeNotifier {
  List<Book> _favourites = [];
  bool _isLoading = false;
  String? _error;

  List<Book> get favourites => _favourites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load favourites from Supabase
  Future<void> loadFavourites(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await Supabase.instance.client
          .from('favourites')
          .select('book_id')
          .eq('user_id', userId);
      final bookIds =
          (data as List).map((e) => e['book_id'] as String).toList();
      _favourites = bookIds
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

  // Add to favourites in Supabase
  Future<void> addToFavourites(String userId, Book book) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (!_favourites.any((b) => b.id == book.id)) {
        await Supabase.instance.client
            .from('favourites')
            .insert({'user_id': userId, 'book_id': book.id});
        _favourites.add(book);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove from favourites in Supabase
  Future<void> removeFromFavourites(String userId, String bookId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Supabase.instance.client
          .from('favourites')
          .delete()
          .eq('user_id', userId)
          .eq('book_id', bookId);
      _favourites.removeWhere((book) => book.id == bookId);
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
}
