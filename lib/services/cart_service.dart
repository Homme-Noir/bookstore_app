import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class CartItem {
  final String bookId;
  final String title;
  final String coverImage;
  final double price;
  final int quantity;

  const CartItem({
    required this.bookId,
    required this.title,
    required this.coverImage,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'coverImage': coverImage,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      bookId: map['bookId'] as String,
      title: map['title'] as String,
      coverImage: map['coverImage'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }
}

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CartItem>> getCartItems(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartItem.fromMap(doc.data()))
            .toList());
  }

  Future<void> addToCart(String userId, Book book, int quantity) async {
    final cartItem = CartItem(
      bookId: book.id,
      title: book.title,
      coverImage: book.coverImage,
      price: book.price,
      quantity: quantity,
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(book.id)
        .set(cartItem.toMap());
  }

  Future<void> removeFromCart(String userId, String bookId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(bookId)
        .delete();
  }

  Future<void> updateCartItemQuantity(
      String userId, String bookId, int quantity) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(bookId)
        .update({'quantity': quantity});
  }

  Future<void> clearCart(String userId) async {
    final cartRef = _firestore.collection('users').doc(userId).collection('cart');
    final snapshot = await cartRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
} 