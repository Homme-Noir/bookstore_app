import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService;
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  CartProvider({
    required CartService cartService,
  }) : _cartService = cartService {
    loadCart();
  }

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get total => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  Future<void> loadCart() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _items = await _cartService.getCartItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(String bookId, int quantity) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _cartService.addToCart(bookId, quantity);
      await loadCart();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String bookId, int quantity) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _cartService.updateQuantity(bookId, quantity);
      await loadCart();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String bookId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _cartService.removeFromCart(bookId);
      await loadCart();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _cartService.clearCart();
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