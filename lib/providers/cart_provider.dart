import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/book.dart';

class CartProvider with ChangeNotifier {
  List<Book> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  List<Book> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _cartItems.length;

  double get totalAmount {
    return _cartItems.fold(0.0, (sum, book) => sum + book.price);
  }

  // Add item to cart
  Future<void> addToCart(Book book) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (!_cartItems.any((item) => item.id == book.id)) {
        _cartItems.add(book);
        await _saveCartToStorage();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String bookId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _cartItems.removeWhere((item) => item.id == bookId);
      await _saveCartToStorage();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _cartItems.clear();
      await _saveCartToStorage();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if item is in cart
  bool isInCart(String bookId) {
    return _cartItems.any((item) => item.id == bookId);
  }

  // Load cart from storage
  Future<void> loadCart() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _loadCartFromStorage();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Save cart to local storage
  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = _cartItems
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
      await prefs.setString('cart', jsonEncode(cartJson));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  // Load cart from local storage
  Future<void> _loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString('cart');

      if (cartString != null) {
        final cartJson = jsonDecode(cartString) as List;
        _cartItems = cartJson
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
      debugPrint('Error loading cart: $e');
      _cartItems = [];
    }
  }
}
