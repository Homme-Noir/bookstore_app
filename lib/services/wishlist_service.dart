import '../mock_data.dart';
import '../models/book.dart';

class WishlistService {
  static final List<String> _mockWishlist = [];

  Stream<List<Book>> getWishlistBooks(String userId) async* {
    yield MockData.books.where((b) => _mockWishlist.contains(b.id)).toList();
  }

  Future<void> addToWishlist(String bookId) async {
    if (!_mockWishlist.contains(bookId)) {
      _mockWishlist.add(bookId);
    }
  }

  Future<void> removeFromWishlist(String bookId) async {
    _mockWishlist.remove(bookId);
  }
}
