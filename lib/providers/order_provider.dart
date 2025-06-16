import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/order.dart';
import '../models/address.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void init(String userId) {
    _orderService.getUserOrders(userId).listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  Future<void> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required ShippingAddress shippingAddress,
    required double total,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _orderService.createOrder(
        userId: userId,
        items: items,
        shippingAddress: shippingAddress,
        total: total,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectOrder(String orderId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _selectedOrder = await _orderService.getOrder(orderId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _orderService.updateOrderStatus(orderId, status);
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