import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService;
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;

  CartProvider({
    required CartService cartService,
    String? userId,
  })  : _cartService = cartService,
        _userId = userId {
    if (_userId != null) {
      loadCart(_userId!);
    }
  }

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get total =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  Future<void> loadCart(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _items = await _cartService.getCartItems(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(String userId, CartItem item) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _cartService.addToCart(userId, item);
      await loadCart(userId);
    } catch (e) {
      _error = e.toString();
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
      await _cartService.updateQuantity(userId, bookId, quantity);
      await loadCart(userId);
    } catch (e) {
      _error = e.toString();
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
      await loadCart(userId);
    } catch (e) {
      _error = e.toString();
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
      _items = [];
    } catch (e) {
      _error = e.toString();
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
