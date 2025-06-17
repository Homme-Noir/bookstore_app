import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reviews';

  // Get reviews for a book
  Stream<List<Review>> getBookReviews(String bookId) {
    return _firestore
        .collection(_collection)
        .where('bookId', isEqualTo: bookId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
    });
  }

  // Add a review
  Future<void> addReview(Review review) async {
    // Add the review
    await _firestore.collection(_collection).add(review.toMap());

    // Update book rating
    final bookReviews = await _firestore
        .collection(_collection)
        .where('bookId', isEqualTo: review.bookId)
        .get();

    final totalRating = bookReviews.docs.fold<double>(
      0,
      (previousValue, doc) =>
          previousValue + (doc.data()['rating'] as num).toDouble(),
    );
    final averageRating = totalRating / bookReviews.docs.length;

    await _firestore.collection('books').doc(review.bookId).update({
      'rating': averageRating,
      'reviewCount': bookReviews.docs.length,
    });
  }

  // Like a review
  Future<void> likeReview(String reviewId, String userId) async {
    final reviewRef = _firestore.collection(_collection).doc(reviewId);
    final reviewDoc = await reviewRef.get();
    final review = Review.fromFirestore(reviewDoc);

    if (review.likedBy.contains(userId)) {
      // Unlike
      await reviewRef.update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      // Like
      await reviewRef.update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  // Delete a review
  Future<void> deleteReview(String reviewId, String bookId) async {
    await _firestore.collection(_collection).doc(reviewId).delete();

    // Update book rating
    final bookReviews = await _firestore
        .collection(_collection)
        .where('bookId', isEqualTo: bookId)
        .get();

    if (bookReviews.docs.isEmpty) {
      await _firestore.collection('books').doc(bookId).update({
        'rating': 0.0,
        'reviewCount': 0,
      });
    } else {
      final totalRating = bookReviews.docs.fold<double>(
        0,
        (previous, doc) => previous + (doc.data()['rating'] as num).toDouble(),
      );
      final averageRating = totalRating / bookReviews.docs.length;

      await _firestore.collection('books').doc(bookId).update({
        'rating': averageRating,
        'reviewCount': bookReviews.docs.length,
      });
    }
  }
}
