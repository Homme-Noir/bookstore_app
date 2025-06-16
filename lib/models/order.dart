import 'package:cloud_firestore/cloud_firestore.dart';
import 'address.dart';
import 'book.dart';

// Add OrderStatus enum
enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderItem {
  final String bookId;
  final String title;
  final double price;
  final int quantity;
  final String coverImage;
  final Book? book;

  const OrderItem({
    required this.bookId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.coverImage,
    this.book,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      bookId: map['bookId'] as String,
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      coverImage: map['coverImage'] as String,
      book: map['book'] != null ? Book.fromJson(map['book']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'price': price,
      'quantity': quantity,
      'coverImage': coverImage,
      if (book != null) 'book': book!.toMap(),
    };
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final ShippingAddress shippingAddress;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? paymentId;
  final String? trackingNumber;
  final String? paymentMethod;
  final double? shippingCost;
  final double? tax;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.paymentId,
    this.trackingNumber,
    this.paymentMethod,
    this.shippingCost,
    this.tax,
  });

  Order copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? totalAmount,
    ShippingAddress? shippingAddress,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentId,
    String? trackingNumber,
    String? paymentMethod,
    double? shippingCost,
    double? tax,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentId: paymentId ?? this.paymentId,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingCost: shippingCost ?? this.shippingCost,
      tax: tax ?? this.tax,
    );
  }

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: data['userId'] as String,
      items: (data['items'] as List)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      shippingAddress: ShippingAddress.fromJson(
        data['shippingAddress'] as Map<String, dynamic>,
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      paymentId: data['paymentId'] as String?,
      trackingNumber: data['trackingNumber'] as String?,
      paymentMethod: data['paymentMethod'] as String?,
      shippingCost: (data['shippingCost'] as num?)?.toDouble(),
      tax: (data['tax'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress.toJson(),
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'paymentId': paymentId,
      'trackingNumber': trackingNumber,
      'paymentMethod': paymentMethod,
      'shippingCost': shippingCost,
      'tax': tax,
    };
  }

  // Computed getters for UI compatibility
  double get subtotal => totalAmount - (shippingCost ?? 0) - (tax ?? 0);
  double get total => totalAmount;
}
