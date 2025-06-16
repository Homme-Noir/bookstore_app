import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../models/book.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get total => _items.fold<double>(
      0, (sum, item) => sum + (item.price * item.quantity));

  void init(String userId) {
    _cartService.getCartItems(userId).listen((items) {
      _items = items;
      notifyListeners();
    });
  }

  Future<void> addToCart(String userId, Book book, int quantity) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _cartService.addToCart(userId, book, quantity);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String userId, String bookId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _cartService.removeFromCart(userId, bookId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(
      String userId, String bookId, int quantity) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _cartService.updateCartItemQuantity(userId, bookId, quantity);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _cartService.clearCart(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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