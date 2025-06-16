import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/cart_service.dart';
import '../services/book_service.dart';
import '../services/order_service.dart';
import '../models/book.dart';
import '../models/order.dart';
import '../models/address.dart';

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
  /// The user service for managing user data.
  final UserService _userService;

  /// The current user of the application.
  User? _user;
  /// The list of categories available in the store.
  List<String> _categories = [];
  /// The list of books in the store.
  List<Book> _books = [];
  /// The list of orders made by the user.
  List<Order> _orders = [];
  /// The list of items in the user's cart.
  List<CartItem> _cartItems = [];

  /// Creates a new instance of AppProvider.
  AppProvider({
    required AuthService authService,
    required BookService bookService,
    required CartService cartService,
    required OrderService orderService,
    required UserService userService,
  })  : _authService = authService,
        _bookService = bookService,
        _cartService = cartService,
        _orderService = orderService,
        _userService = userService {
    _init();
  }

  /// Initializes the provider by setting up listeners for user changes and loading initial data.
  Future<void> _init() async {
    _authService.onAuthStateChanged.listen((user) {
      _user = user;
      if (user != null) {
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
    if (_user == null) return;

    _cartService.getCartItems(_user!.uid).listen((items) {
      _cartItems = items;
      notifyListeners();
    });

    _orderService.getUserOrders(_user!.uid).listen((orders) {
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
    _categories = await _bookService.getCategories();
    notifyListeners();
  }

  /// Loads the list of books from the book service.
  Future<void> _loadBooks() async {
    _books = await _bookService.getBooks();
    notifyListeners();
  }

  /// Returns the current user.
  User? get user => _user;

  /// Returns the list of categories.
  List<String> get categories => _categories;

  /// Returns the list of books.
  List<Book> get books => _books;

  /// Returns the list of orders made by the user.
  List<Order> get orders => _orders;

  /// Returns the list of items in the user's cart.
  List<CartItem> get cartItems => _cartItems;

  /// Returns the total number of items in the user's cart.
  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Returns the total price of items in the user's cart.
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  /// Signs in a user with the provided email and password.
  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
  }

  /// Signs up a new user with the provided email and password.
  Future<void> signUp(String email, String password) async {
    await _authService.signUp(email, password);
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Adds a book to the user's cart.
  Future<void> addToCart(Book book, int quantity) async {
    if (_user == null) return;
    await _cartService.addToCart(_user!.uid, book, quantity);
  }

  /// Removes a book from the user's cart.
  Future<void> removeFromCart(String bookId) async {
    if (_user == null) return;
    await _cartService.removeFromCart(_user!.uid, bookId);
  }

  /// Updates the quantity of a book in the user's cart.
  Future<void> updateCartItemQuantity(String bookId, int quantity) async {
    if (_user == null) return;
    await _cartService.updateCartItemQuantity(_user!.uid, bookId, quantity);
  }

  /// Clears the user's cart.
  Future<void> clearCart() async {
    if (_user == null) return;
    await _cartService.clearCart(_user!.uid);
  }

  /// Places an order with the provided shipping address and payment method.
  Future<void> placeOrder({
    required List<Map<String, dynamic>> items,
    required ShippingAddress address,
    required double total,
  }) async {
    if (_user == null) return;
    await _orderService.createOrder(
      userId: _user!.uid,
      items: items,
      shippingAddress: address,
      total: total,
    );
    await clearCart();
  }

  /// Returns a stream of books filtered by category and sort option.
  Stream<List<Book>> getBooksFiltered({String? category, String? sort, int? pageSize}) {
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
  Stream<List> getUserOrdersStream() {
    if (_user == null) return Stream.value([]);
    return _orderService.getUserOrders(_user!.uid);
  }

  /// Returns a stream of items in the user's cart.
  Stream<List<CartItem>> getCartStream() {
    if (_user == null) return Stream.value([]);
    return _cartService.getCartItems(_user!.uid);
  }
} 