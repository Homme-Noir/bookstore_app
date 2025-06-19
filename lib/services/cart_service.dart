import '../models/book.dart';
import '../models/cart_item.dart';
import '../mock_data.dart';

class CartService {
  static final List<CartItem> _mockCart = [];

  Future<List<CartItem>> getCartItems() async {
    return _mockCart;
  }

  Stream<List<CartItem>> getCartStream() async* {
    yield _mockCart;
  }

  Future<void> addToCart(String bookId, int quantity) async {
    final idx = _mockCart.indexWhere((c) => c.bookId == bookId);
    if (idx != -1) {
      _mockCart[idx] =
          _mockCart[idx].copyWith(quantity: _mockCart[idx].quantity + quantity);
    } else {
      Book? book;
      for (final b in MockData.books) {
        if (b.id == bookId) {
          book = b;
          break;
        }
      }
      _mockCart.add(CartItem(
        bookId: bookId,
        title: book?.title ?? '',
        coverImage: book?.coverImage ?? '',
        price: book?.price ?? 0.0,
        quantity: quantity,
      ));
    }
  }

  Future<void> removeFromCart(String bookId) async {
    _mockCart.removeWhere((c) => c.bookId == bookId);
  }

  Future<void> updateQuantity(String bookId, int quantity) async {
    final idx = _mockCart.indexWhere((c) => c.bookId == bookId);
    if (idx != -1) {
      _mockCart[idx] = _mockCart[idx].copyWith(quantity: quantity);
    }
  }

  Future<void> clearCart() async {
    _mockCart.clear();
  }
}
