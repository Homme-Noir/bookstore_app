import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartProvider with ChangeNotifier {
  List<Book> _cartItems = [];
  bool _isLoading = false;
  String? _error;
  RealtimeChannel? _cartSubscription;

  List<Book> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _cartItems.length;

  double get totalAmount {
    return _cartItems.fold(0.0, (sum, book) => sum + book.price);
  }

  /// Subscribe to real-time cart changes
  void subscribeToCartChanges(String userId) {
    _cartSubscription?.unsubscribe();
    _cartSubscription = Supabase.instance.client
        .channel('cart_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'cart',
          callback: (payload) {
            loadCart(userId);
          },
        )
        .subscribe();
  }

  /// Unsubscribe from real-time cart changes
  void unsubscribeFromCartChanges() {
    _cartSubscription?.unsubscribe();
    _cartSubscription = null;
  }

  /// Add item to cart in Supabase
  Future<void> addToCart(String userId, Book book) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if item already exists in cart
      final existingItem = await Supabase.instance.client
          .from('cart')
          .select()
          .eq('user_id', userId)
          .eq('book_id', book.id)
          .maybeSingle();

      if (existingItem == null) {
        // Add new item
        await Supabase.instance.client.from('cart').insert({
          'user_id': userId,
          'book_id': book.id,
          'quantity': 1,
        });
      } else {
        // Update quantity
        await Supabase.instance.client
            .from('cart')
            .update({'quantity': existingItem['quantity'] + 1})
            .eq('user_id', userId)
            .eq('book_id', book.id);
      }

      // Reload cart to get updated data
      await loadCart(userId);
    } catch (e) {
      _error = 'Failed to add to cart: ${e.toString()}';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove item from cart in Supabase
  Future<void> removeFromCart(String userId, String bookId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Supabase.instance.client
          .from('cart')
          .delete()
          .eq('user_id', userId)
          .eq('book_id', bookId);

      // Reload cart to get updated data
      await loadCart(userId);
    } catch (e) {
      _error = 'Failed to remove from cart: ${e.toString()}';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update item quantity in cart
  Future<void> updateQuantity(
      String userId, String bookId, int quantity) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (quantity <= 0) {
        await removeFromCart(userId, bookId);
      } else {
        await Supabase.instance.client
            .from('cart')
            .update({'quantity': quantity})
            .eq('user_id', userId)
            .eq('book_id', bookId);
      }

      // Reload cart to get updated data
      await loadCart(userId);
    } catch (e) {
      _error = 'Failed to update quantity: ${e.toString()}';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear cart in Supabase
  Future<void> clearCart(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Supabase.instance.client
          .from('cart')
          .delete()
          .eq('user_id', userId);

      _cartItems.clear();
    } catch (e) {
      _error = 'Failed to clear cart: ${e.toString()}';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if item is in cart
  bool isInCart(String bookId) {
    return _cartItems.any((item) => item.id == bookId);
  }

  /// Get quantity of item in cart
  int getQuantity(String bookId) {
    final item = _cartItems.firstWhere(
      (item) => item.id == bookId,
      orElse: () => Book(
        id: bookId,
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
        pageCount: 0,
      ),
    );
    return item.stock; // Using stock field to store quantity for now
  }

  /// Load cart from Supabase with book details
  Future<void> loadCart(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Join cart with books table to get full book details
      final response = await Supabase.instance.client.from('cart').select('''
            quantity,
            books (
              id,
              title,
              author,
              description,
              cover_image,
              price,
              genres,
              stock,
              rating,
              review_count,
              release_date,
              is_bestseller,
              is_new_arrival,
              isbn,
              page_count
            )
          ''').eq('user_id', userId);

      _cartItems = (response as List).map((item) {
        final bookData = item['books'] as Map<String, dynamic>;
        final book = Book(
          id: bookData['id'] ?? '',
          title: bookData['title'] ?? '',
          author: bookData['author'] ?? '',
          description: bookData['description'] ?? '',
          coverImage: bookData['cover_image'] ?? '',
          price: (bookData['price'] ?? 0.0).toDouble(),
          genres: List<String>.from(bookData['genres'] ?? []),
          stock: item['quantity'] ?? 1, // Store quantity in stock field
          rating: (bookData['rating'] ?? 0.0).toDouble(),
          reviewCount: bookData['review_count'] ?? 0,
          releaseDate: DateTime.tryParse(bookData['release_date'] ?? '') ??
              DateTime.now(),
          isBestseller: bookData['is_bestseller'] ?? false,
          isNewArrival: bookData['is_new_arrival'] ?? false,
          isbn: bookData['isbn'] ?? '',
          pageCount: bookData['page_count'] ?? 0,
        );
        return book;
      }).toList();
    } catch (e) {
      _error = 'Failed to load cart: ${e.toString()}';
      debugPrint('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    unsubscribeFromCartChanges();
    super.dispose();
  }
}
