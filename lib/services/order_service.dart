import '../models/order.dart';
import '../models/address.dart';

class OrderService {
  static final List<Order> _mockOrders = [];

  Stream<List<Order>> getUserOrders(String userId) async* {
    yield _mockOrders.where((o) => o.userId == userId).toList();
  }

  Future<void> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required ShippingAddress shippingAddress,
    required double total,
  }) async {
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      items: [], // You can map items to OrderItem if needed
      totalAmount: total,
      shippingAddress: shippingAddress,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _mockOrders.add(order);
  }

  Stream<List<Order>> getAllOrders() async* {
    yield _mockOrders;
  }

  Future<List<Order>> getAllOrdersFuture() async {
    return _mockOrders;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final idx = _mockOrders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _mockOrders[idx] = _mockOrders[idx].copyWith(status: status);
    }
  }
}
