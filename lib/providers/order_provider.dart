import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../models/address.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService;
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  OrderProvider({
    required OrderService orderService,
  }) : _orderService = orderService {
    loadOrders("");
  }

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _orders = await _orderService.getUserOrders(userId).first;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      await loadOrders(userId);
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

      final allOrders = await _orderService.getAllOrdersFuture();
      Order? found;
      for (final o in allOrders) {
        if (o.id == orderId) {
          found = o;
          break;
        }
      }
      _selectedOrder = found;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _orderService.updateOrderStatus(orderId, status);
      await loadOrders("");
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
