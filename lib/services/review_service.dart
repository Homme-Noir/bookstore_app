import '../models/review.dart';

class ReviewService {
  static final List<Review> _mockReviews = [];

  Stream<List<Review>> getBookReviews(String bookId) async* {
    yield _mockReviews.where((r) => r.bookId == bookId).toList();
  }

  Future<void> addReview(Review review) async {
    _mockReviews.add(review);
  }

  Future<void> deleteReview(String reviewId) async {
    _mockReviews.removeWhere((r) => r.id == reviewId);
  }
}
