import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart' as model;
import '../models/address.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  /// Fetch all orders for the current user
  Future<List<model.Order>> getOrders() async {
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: _getCurrentUserId())
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => model.Order.fromFirestore(doc)).toList();
  }

  /// Place a new order
  Future<void> placeOrder(model.Order order) async {
    final docRef = await _firestore.collection('orders').add(order.toMap());
    await docRef.update({'id': docRef.id});
  }

  /// Fetch orders for a specific user
  Stream<List<model.Order>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
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
          (snapshot) => snapshot.docs
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
      status: model.OrderStatus.pending,
      createdAt: now,
      updatedAt: now,
    );

    final docRef = await _firestore.collection('orders').add(order.toMap());

    // Return a new instance of the order with the generated ID
    return order.copyWith(id: docRef.id);
  }

  /// Update the order status
  Future<void> updateOrderStatus(
      String orderId, model.OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.toString().split('.').last,
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

  /// Fetch all orders as a Future (admin functionality)
  Future<List<model.Order>> getAllOrdersFuture() async {
    final snapshot = await _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => model.Order.fromFirestore(doc)).toList();
  }
}
