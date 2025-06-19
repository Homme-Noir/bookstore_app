import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_data.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  String? _userId;
  UserData? _userData;
  bool _isLoading = false;
  String? _error;

  AuthProvider({
    required AuthService authService,
  }) : _authService = authService {
    _init();
  }

  String? get userId => _userId;
  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _userId != null;

  void _init() {
    _authService.onAuthStateChanged.listen((Map<String, String>? user) {
      _userId = user?['uid'];
      if (_userId != null) {
        // _loadUserData(); // Remove or stub if not needed
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signIn(email, password);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, UserData userData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signUp(email, password);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signOut();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.resetPassword(email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.signUp(email, password);
      _userId = user['uid'];
      return _userId ?? '';
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
