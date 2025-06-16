import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item.dart';
import '../models/book.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  Future<List<CartItem>> getCartItems() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_getCurrentUserId())
        .collection('cart')
        .get();
    return snapshot.docs.map((doc) => CartItem.fromMap(doc.data())).toList();
  }

  Stream<List<CartItem>> getCartStream() {
    return _firestore
        .collection('users')
        .doc(_getCurrentUserId())
        .collection('cart')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CartItem.fromMap(doc.data())).toList());
  }

  Future<void> addToCart(String bookId, int quantity) async {
    final book = await _getBook(bookId);
    final cartItem = CartItem(
      bookId: book.id,
      title: book.title,
      coverImage: book.coverImage,
      price: book.price,
      quantity: quantity,
    );

    await _firestore
        .collection('users')
        .doc(_getCurrentUserId())
        .collection('cart')
        .doc(bookId)
        .set(cartItem.toMap());
  }

  Future<void> updateQuantity(String bookId, int quantity) async {
    await _firestore
        .collection('users')
        .doc(_getCurrentUserId())
        .collection('cart')
        .doc(bookId)
        .update({'quantity': quantity});
  }

  Future<void> removeFromCart(String bookId) async {
    await _firestore
        .collection('users')
        .doc(_getCurrentUserId())
        .collection('cart')
        .doc(bookId)
        .delete();
  }

  Future<void> clearCart() async {
    final cartRef = _firestore
        .collection('users')
        .doc(_getCurrentUserId())
        .collection('cart');
    final snapshot = await cartRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<Book> _getBook(String bookId) async {
    final doc = await _firestore.collection('books').doc(bookId).get();
    if (!doc.exists) {
      throw Exception('Book not found');
    }
    return Book.fromFirestore(doc);
  }
}
