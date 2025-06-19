import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/book_service.dart';
import '../services/order_service.dart';
import '../models/book.dart';
import '../models/order.dart' as model;
import '../models/address.dart';
import '../models/cart_item.dart';

enum PaymentMethod {
  creditCard,
  debitCard,
  paypal,
  cashOnDelivery,
}

/// A provider class that manages the application state and services.
class AppProvider extends ChangeNotifier {
  /// The authentication service for user management.
  final AuthService _authService;

  /// The book service for managing book data.
  final BookService _bookService;

  /// The cart service for managing the shopping cart.
  final CartService _cartService;

  /// The order service for managing orders.
  final OrderService _orderService;

  /// The Firestore instance for accessing Firestore.
  final firestore.FirebaseFirestore _firestore;

  /// The current user of the application.
  String? _userId;

  /// The list of categories available in the store.
  List<String> _categories = [];

  /// The list of books in the store.
  List<Book> _books = [];

  /// The list of orders made by the user.
  List<model.Order> _orders = [];

  /// The list of items in the user's cart.
  List<CartItem> _cartItems = [];

  /// The current theme mode of the application.
  ThemeMode _themeMode = ThemeMode.system;

  /// Returns whether the provider is currently loading data.
  final bool _isLoading = false;

  /// Returns whether the user is authenticated.
  bool get isAuthenticated => _userId != null;

  /// Returns whether the provider is currently loading data.
  bool get isLoading => _isLoading;

  /// Returns the current theme mode.
  ThemeMode get themeMode => _themeMode;

  /// Creates a new instance of AppProvider.
  AppProvider({
    required AuthService authService,
    required BookService bookService,
    required CartService cartService,
    required OrderService orderService,
    required firestore.FirebaseFirestore firestore,
  })  : _authService = authService,
        _bookService = bookService,
        _cartService = cartService,
        _orderService = orderService,
        _firestore = firestore {
    _init();
  }

  /// Sets the theme mode of the application.
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Initializes the provider by setting up listeners for user changes and loading initial data.
  Future<void> _init() async {
    _authService.onAuthStateChanged.listen((user) {
      _userId = user?['uid'];
      if (_userId != null) {
        _loadUserData();
      } else {
        _clearUserData();
      }
      notifyListeners();
    });

    _loadCategories();
    _loadBooks();
  }

  /// Loads user-specific data such as cart and orders.
  Future<void> _loadUserData() async {
    if (_userId == null) return;

    _cartItems = await _cartService.getCartItems();
    notifyListeners();

    _orderService.getUserOrders(_userId!).listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  /// Clears user-specific data when the user logs out.
  void _clearUserData() {
    _cartItems = [];
    _orders = [];
    notifyListeners();
  }

  /// Loads the list of categories from the book service.
  Future<void> _loadCategories() async {
    // Use mock data for categories
    _categories = ['Fiction', 'Classic', 'Fantasy', 'Romance', 'Adventure'];
    notifyListeners();
  }

  /// Loads the list of books from the book service.
  void _loadBooks() {
    _books = _bookService.getBooks();
    notifyListeners();
  }

  /// Returns the current user.
  String? get userId => _userId;

  /// Returns the list of categories.
  List<String> get categories => _categories;

  /// Returns the list of books.
  List<Book> get books => _books;

  /// Returns the list of orders made by the user.
  List<model.Order> get orders => _orders;

  /// Returns the list of items in the user's cart.
  List<CartItem> get cartItems => _cartItems;

  /// Returns the total number of items in the user's cart.
  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Returns the total price of items in the user's cart.
  double get cartTotal =>
      _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  /// Signs in a user with the provided email and password.
  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
  }

  /// Signs up a new user with the provided email and password.
  Future<String> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    final user = await _authService.signUp(email, password);
    return user['uid'] ?? '';
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Adds a book to the user's cart.
  Future<void> addToCart(Book book, int quantity) async {
    if (_userId == null) return;
    await _cartService.addToCart(book.id, quantity);
  }

  /// Removes a book from the user's cart.
  Future<void> removeFromCart(String bookId) async {
    if (_userId == null) return;
    await _cartService.removeFromCart(bookId);
  }

  /// Updates the quantity of a book in the user's cart.
  Future<void> updateCartItemQuantity(String bookId, int quantity) async {
    if (_userId == null) return;
    await _cartService.updateQuantity(bookId, quantity);
  }

  /// Clears the user's cart.
  Future<void> clearCart() async {
    if (_userId == null) return;
    await _cartService.clearCart();
  }

  /// Places an order with the provided shipping address and payment method.
  Future<void> placeOrder({
    required List<Map<String, dynamic>> items,
    required ShippingAddress address,
    required double total,
  }) async {
    if (_userId == null) return;
    await _orderService.createOrder(
      userId: _userId!,
      items: items,
      shippingAddress: address,
      total: total,
    );
    await clearCart();
  }

  /// Returns a stream of books filtered by category and sort option.
  Stream<List<Book>> getBooksFiltered(
      {String? category, String? sort, int? pageSize}) {
    return _bookService.getBooksStream();
  }

  /// Returns a stream of bestseller books.
  Stream<List<Book>> getBestsellers() {
    return _bookService.getBooksStream();
  }

  /// Returns a stream of new arrival books.
  Stream<List<Book>> getNewArrivals() {
    return _bookService.getBooksStream();
  }

  /// Returns a stream of orders made by the user.
  Stream<List<model.Order>> getUserOrdersStream() {
    if (_userId == null) return Stream.value([]);
    return _orderService.getUserOrders(_userId!);
  }

  /// Returns a stream of items in the user's cart.
  Stream<List<CartItem>> getCartStream() {
    if (_userId == null) return Stream.value([]);
    return _cartService.getCartStream();
  }

  /// Adds a new book to the store.
  Future<void> addBook(Book book) async {
    await _bookService.addBook(book);
    _loadBooks();
  }

  /// Updates an existing book in the store.
  Future<void> updateBook(Book book) async {
    await _bookService.updateBook(book);
    _loadBooks();
  }

  /// Deletes a book from the store.
  Future<void> deleteBook(String bookId) async {
    await _bookService.deleteBook(bookId);
    _loadBooks();
  }

  /// Gets all books from the store.
  Future<List<Book>> getAllBooks() async {
    return _bookService.getBooks();
  }

  /// Gets all categories from the store.
  Future<List<String>> getAllCategories() async {
    return await _bookService.getCategories();
  }

  /// Adds a new category to the store.
  Future<void> addCategory(String category) async {
    await _bookService.addCategory(category);
    await _loadCategories();
  }

  /// Updates an existing category in the store.
  Future<void> updateCategory(String oldCategory, String newCategory) async {
    await _bookService.updateCategory(oldCategory, newCategory);
    await _loadCategories();
  }

  /// Deletes a category from the store.
  Future<void> deleteCategory(String category) async {
    await _bookService.deleteCategory(category);
    await _loadCategories();
  }

  /// Gets all orders from the store.
  Future<List<model.Order>> getAllOrders() async {
    return await _orderService.getAllOrdersFuture();
  }

  /// Updates the status of an order.
  Future<void> updateOrderStatus(
      String orderId, model.OrderStatus status) async {
    await _orderService.updateOrderStatus(orderId, status);
  }

  /// Gets all books from the store as a stream.
  Stream<List<Book>> getAllBooksStream() {
    return _bookService.getBooksStream();
  }

  /// Gets all categories from the store as a stream.
  Stream<List<String>> getAllCategoriesStream() {
    // Return a stream of the mock categories
    return Stream.value(
        ['Fiction', 'Classic', 'Fantasy', 'Romance', 'Adventure']);
  }

  /// Gets all orders from the store as a stream.
  Stream<List<model.Order>> getAllOrdersStream() {
    return _orderService.getAllOrders();
  }

  /// Returns a stream of books in the user's wishlist.
  Stream<List<Book>> getWishlistBooks() {
    // Return an empty stream or implement a mock wishlist if needed
    return Stream.value([]);
  }

  /// Checks if a book is in the user's wishlist.
  Future<bool> isInWishlist(String bookId) async {
    if (_userId == null) return false;
    final doc = await _firestore
        .collection('users')
        .doc(_userId!)
        .collection('wishlist')
        .doc(bookId)
        .get();
    return doc.exists;
  }

  /// Adds a book to the user's wishlist.
  Future<void> addToWishlist(String bookId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId!)
        .collection('wishlist')
        .doc(bookId)
        .set({'addedAt': firestore.FieldValue.serverTimestamp()});
  }

  /// Removes a book from the user's wishlist.
  Future<void> removeFromWishlist(String bookId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId!)
        .collection('wishlist')
        .doc(bookId)
        .delete();
  }

  /// Returns a stream of reviews for a book.
  Stream<List<Map<String, dynamic>>> getBookReviews(String bookId) {
    return _firestore
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// Adds a review to a book.
  Future<void> addReview(String bookId, String text, double rating) async {
    if (_userId == null) return;
    await _firestore.collection('books').doc(bookId).collection('reviews').add({
      'userId': _userId!,
      'userName': 'Anonymous',
      'text': text,
      'rating': rating,
      'timestamp': firestore.FieldValue.serverTimestamp(),
      'likes': 0,
    });
  }

  /// Likes a review.
  Future<void> likeReview(String bookId, String reviewId) async {
    if (_userId == null) return;
    final reviewRef = _firestore
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .doc(reviewId);

    final review = await reviewRef.get();
    if (!review.exists) return;

    final likedBy = List<String>.from(review.data()?['likedBy'] ?? []);
    if (likedBy.contains(_userId!)) {
      likedBy.remove(_userId!);
      await reviewRef.update({
        'likes': firestore.FieldValue.increment(-1),
        'likedBy': likedBy,
      });
    } else {
      likedBy.add(_userId!);
      await reviewRef.update({
        'likes': firestore.FieldValue.increment(1),
        'likedBy': likedBy,
      });
    }
  }

  /// Returns a stream of bestseller books filtered by category.
  Stream<List<Book>> getBestsellersFiltered({String? category}) {
    return _bookService.getBooksStream().map((books) {
      var filtered = books.where((book) => book.isBestseller).toList();
      if (category != null) {
        filtered =
            filtered.where((book) => book.genres.contains(category)).toList();
      }
      return filtered;
    });
  }

  /// Returns a stream of new arrival books filtered by category.
  Stream<List<Book>> getNewArrivalsFiltered({String? category}) {
    return _bookService.getBooksStream().map((books) {
      var filtered = books.where((book) => book.isNewArrival).toList();
      if (category != null) {
        filtered =
            filtered.where((book) => book.genres.contains(category)).toList();
      }
      return filtered;
    });
  }

  /// Resets the password for a user with the provided email.
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  /// Creates a payment intent with Stripe for the given amount.
  // Stripe payment logic removed. No-op or mock logic can be added if needed.
}
