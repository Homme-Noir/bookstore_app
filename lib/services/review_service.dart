import 'dart:convert';
import 'db_helper.dart';
import '../models/review.dart';

class ReviewService {
  final DBHelper _dbHelper = DBHelper();

  Future<List<Review>> getBookReviews(String bookId) async {
    final db = await _dbHelper.db;
    final result =
        await db.query('reviews', where: 'bookId = ?', whereArgs: [bookId]);
    return result.map((e) => Review.fromMap(e)).toList();
  }

  Future<void> addReview(Review review) async {
    final db = await _dbHelper.db;
    await db.insert('reviews', review.toMap());
  }

  Future<void> likeReview(String reviewId, String userId) async {
    final db = await _dbHelper.db;
    final result =
        await db.query('reviews', where: 'id = ?', whereArgs: [reviewId]);
    if (result.isNotEmpty) {
      final review = Review.fromMap(result.first);
      final likedBy = List<String>.from(json.decode(review.likedBy ?? '[]'));
      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
      } else {
        likedBy.add(userId);
      }
      await db.update(
          'reviews',
          {
            'likes': likedBy.length,
            'likedBy': json.encode(likedBy),
          },
          where: 'id = ?',
          whereArgs: [reviewId]);
    }
  }

  // Delete a review
  Future<void> deleteReview(String reviewId, String bookId) async {
    final db = await _dbHelper.db;
    await db.delete('reviews', where: 'id = ?', whereArgs: [reviewId]);

    // Update book rating
    final bookReviews =
        await db.query('reviews', where: 'bookId = ?', whereArgs: [bookId]);

    if (bookReviews.isEmpty) {
      await db.update(
          'books',
          {
            'rating': 0.0,
            'reviewCount': 0,
          },
          where: 'id = ?',
          whereArgs: [bookId]);
    } else {
      final totalRating = bookReviews.fold<double>(
        0,
        (previous, doc) => previous + (doc['rating'] as num).toDouble(),
      );
      final averageRating = totalRating / bookReviews.length;

      await db.update(
          'books',
          {
            'rating': averageRating,
            'reviewCount': bookReviews.length,
          },
          where: 'id = ?',
          whereArgs: [bookId]);
    }
  }
}
