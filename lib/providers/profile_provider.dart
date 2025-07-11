import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Order {
  final String id;
  final List<Book> books;
  final double totalAmount;
  final DateTime orderDate;
  final String status;

  Order({
    required this.id,
    required this.books,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'books': books
          .map((book) => {
                'id': book.id,
                'title': book.title,
                'author': book.author,
                'coverImage': book.coverImage,
                'price': book.price,
              })
          .toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      books: (json['books'] as List)
          .map((bookJson) => Book(
                id: bookJson['id'],
                title: bookJson['title'],
                author: bookJson['author'],
                description: '',
                coverImage: bookJson['coverImage'],
                price: bookJson['price'].toDouble(),
                genres: [],
                stock: 0,
                rating: 0.0,
                reviewCount: 0,
                releaseDate: DateTime.now(),
                isBestseller: false,
                isNewArrival: false,
                isbn: '',
                pageCount: 0,
              ))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      orderDate: DateTime.parse(json['orderDate']),
      status: json['status'],
    );
  }
}

class ProfileProvider with ChangeNotifier {
  String _email = '';
  String _displayName = '';
  List<Order> _orderHistory = [];
  bool _isLoading = false;
  String? _error;

  String get email => _email;
  String get displayName => _displayName;
  List<Order> get orderHistory => _orderHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load profile data from Supabase
  Future<void> loadProfile(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await Supabase.instance.client
          .from('profiles')
          .select('full_name, email')
          .eq('id', userId)
          .single();
      _displayName = data['full_name'] ?? '';
      _email = data['email'] ?? '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update email in Supabase
  Future<void> updateEmail(String userId, String newEmail) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Supabase.instance.client
          .from('profiles')
          .update({'email': newEmail})
          .eq('id', userId)
          .single();
      _email = newEmail;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update display name in Supabase
  Future<void> updateDisplayName(String userId, String newDisplayName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Supabase.instance.client
          .from('profiles')
          .update({'full_name': newDisplayName})
          .eq('id', userId)
          .single();
      _displayName = newDisplayName;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load order history from Supabase
  Future<void> loadOrderHistory(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await Supabase.instance.client
          .from('orders')
          .select('id, total_amount, status, order_date, order_items(book_id, quantity, price)')
          .eq('user_id', userId)
          .order('order_date', ascending: false);
      final orders = (data as List)
          .map((orderJson) => Order(
                id: orderJson['id'],
                books: (orderJson['order_items'] as List)
                    .map((item) => Book(
                        id: item['book_id'],
                        title: '',
                        author: '',
                        description: '',
                        coverImage: '',
                        price: (item['price'] ?? 0.0).toDouble(),
                        genres: [],
                        stock: 0,
                        rating: 0.0,
                        reviewCount: 0,
                        releaseDate: DateTime.now(),
                        isBestseller: false,
                        isNewArrival: false,
                        isbn: '',
                        pageCount: 0))
                    .toList(),
                totalAmount: (orderJson['total_amount'] ?? 0.0).toDouble(),
                orderDate: DateTime.parse(orderJson['order_date']),
                status: orderJson['status'],
              ))
          .toList();
      _orderHistory = orders;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add order to Supabase
  Future<void> addOrder(
      String userId, List<Book> books, double totalAmount) async {
    try {
      final orderData = await Supabase.instance.client
          .from('orders')
          .insert({
            'user_id': userId,
            'total_amount': totalAmount,
            'status': 'Completed'
          })
          .select()
          .single();
      final orderId = orderData['id'];
      final orderItems = books
          .map((book) => {
                'order_id': orderId,
                'book_id': book.id,
                'quantity': 1,
                'price': book.price,
              })
          .toList();
      await Supabase.instance.client.from('order_items').insert(orderItems);
      await loadOrderHistory(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
