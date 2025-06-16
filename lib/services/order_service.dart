import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as model;
import '../models/address.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch orders for a specific user
  Stream<List<model.Order>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => model.Order.fromFirestore(doc))
                  .toList(),
        );
  }

  /// Fetch all orders (admin functionality)
  Stream<List<model.Order>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => model.Order.fromFirestore(doc))
                  .toList(),
        );
  }

  /// Fetch a single order by ID
  Future<model.Order?> getOrder(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (!doc.exists) return null;
    return model.Order.fromFirestore(doc);
  }

  /// Create a new order
  Future<model.Order> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required ShippingAddress shippingAddress,
    required double total,
  }) async {
    final now = DateTime.now();

    final order = model.Order(
      id: '', // Will be replaced after Firestore document is created
      userId: userId,
      items: items.map((item) => model.OrderItem.fromMap(item)).toList(),
      totalAmount: total,
      shippingAddress: shippingAddress,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    );

    final docRef = await _firestore.collection('orders').add(order.toMap());

    // Return a new instance of the order with the generated ID
    return order.copyWith(id: docRef.id);
  }

  /// Update the order status (e.g., from 'pending' to 'shipped')
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Add tracking number (optional)
  Future<void> updateTrackingNumber(
    String orderId,
    String trackingNumber,
  ) async {
    await _firestore.collection('orders').doc(orderId).update({
      'trackingNumber': trackingNumber,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Add payment ID (optional)
  Future<void> updatePaymentId(String orderId, String paymentId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'paymentId': paymentId,
      'updatedAt': Timestamp.now(),
    });
  }
}
