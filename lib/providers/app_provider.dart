import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Global session and theme mode, driven by [AuthService] auth state stream.
class AppProvider extends ChangeNotifier {
  final AuthService _authService;

  String? _userId;
  ThemeMode _themeMode = ThemeMode.system;
  Map<String, dynamic>? _currentUser;

  ThemeMode get themeMode => _themeMode;
  bool get isAuthenticated => _userId != null;
  String? get userId => _userId;

  AppProvider({
    required AuthService authService,
  }) : _authService = authService {
    _init();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void _init() {
    _authService.onAuthStateChanged.listen((user) {
      _userId = user?['uid'];
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _currentUser = await _authService.signIn(email, password);
    _userId = _currentUser?['uid'] as String?;
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    await _authService.signUp(email, password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _userId = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  String? get currentUserEmail {
    final user = _currentUser ?? _authService.currentUser;
    if (user != null && user['email'] != null) {
      return user['email'] as String;
    }
    return null;
  }
}
