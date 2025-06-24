import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/book.dart';

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

  // Load profile data
  Future<void> loadProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _loadProfileFromStorage();
      await _loadOrderHistory();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _email = newEmail;
      await _saveProfileToStorage();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update display name
  Future<void> updateDisplayName(String newDisplayName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _displayName = newDisplayName;
      await _saveProfileToStorage();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add order to history
  Future<void> addOrder(List<Book> books, double totalAmount) async {
    try {
      final order = Order(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        books: books,
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        status: 'Completed',
      );

      _orderHistory.insert(0, order); // Add to beginning
      await _saveOrderHistory();
      notifyListeners();
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

  // Save profile to local storage
  Future<void> _saveProfileToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileData = {
        'email': _email,
        'displayName': _displayName,
      };
      await prefs.setString('profile', jsonEncode(profileData));
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  // Load profile from local storage
  Future<void> _loadProfileFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileString = prefs.getString('profile');

      if (profileString != null) {
        final profileData = jsonDecode(profileString) as Map<String, dynamic>;
        _email = profileData['email'] ?? '';
        _displayName = profileData['displayName'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      _email = '';
      _displayName = '';
    }
  }

  // Save order history to local storage
  Future<void> _saveOrderHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderHistoryJson =
          _orderHistory.map((order) => order.toJson()).toList();
      await prefs.setString('order_history', jsonEncode(orderHistoryJson));
    } catch (e) {
      debugPrint('Error saving order history: $e');
    }
  }

  // Load order history from local storage
  Future<void> _loadOrderHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderHistoryString = prefs.getString('order_history');

      if (orderHistoryString != null) {
        final orderHistoryJson = jsonDecode(orderHistoryString) as List;
        _orderHistory = orderHistoryJson
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading order history: $e');
      _orderHistory = [];
    }
  }
}
