import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_data.dart';
import '../services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;
  UserData? _user;
  UserData? _userData;
  bool _isLoading = false;
  String? _error;

  AuthProvider({
    required AuthService authService,
    required UserService userService,
  })  : _authService = authService,
        _userService = userService {
    // _init();
  }

  UserData? get user => _user;
  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // void _init() {
  //   // No auth state stream for SQLite
  // }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _user = await _authService.signIn(email, password);
      if (_user != null) {
        _userData = await _userService.getUserData(_user!.id);
      }
      notifyListeners();
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
      final newUser = await _authService.signUp(email, password, userData.name);
      await _userService.createUserData(newUser, password: password);
      _user = newUser;
      _userData = newUser;
      notifyListeners();
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
      _user = null;
      _userData = null;
      notifyListeners();
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
