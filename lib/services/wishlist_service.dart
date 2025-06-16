import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'wishlists';

  // Get user's wishlist
  Stream<List<Book>> getUserWishlist(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('items')
        .snapshots()
        .asyncMap((snapshot) async {
      final bookIds = snapshot.docs.map((doc) => doc.id).toList();
      if (bookIds.isEmpty) return [];

      final booksSnapshot = await _firestore
          .collection('books')
          .where(FieldPath.documentId, whereIn: bookIds)
          .get();

      return booksSnapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }

  // Add book to wishlist
  Future<void> addToWishlist(String userId, String bookId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('items')
        .doc(bookId)
        .set({
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove book from wishlist
  Future<void> removeFromWishlist(String userId, String bookId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('items')
        .doc(bookId)
        .delete();
  }

  // Check if book is in wishlist
  Future<bool> isInWishlist(String userId, String bookId) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(userId)
        .collection('items')
        .doc(bookId)
        .get();
    return doc.exists;
  }

  // Get user's wishlist as a Future
  Future<List<Book>> getWishlist(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .doc(userId)
        .collection('items')
        .get();

    final bookIds = snapshot.docs.map((doc) => doc.id).toList();
    if (bookIds.isEmpty) return [];

    final booksSnapshot = await _firestore
        .collection('books')
        .where(FieldPath.documentId, whereIn: bookIds)
        .get();

    return booksSnapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
  }
} 