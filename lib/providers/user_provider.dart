import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;
  UserData? _userData;
  bool _isLoading = false;
  String? _error;

  UserProvider({
    UserService? userService,
  }) : _userService = userService ?? UserService();

  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Stub loadUserData for mock
  void loadUserData(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();
    _userData = _userService.getUserById(userId);
    _isLoading = false;
    notifyListeners();
  }

  // Stub updateUserData for mock
  void updateUserData(UserData userData) {
    _isLoading = true;
    _error = null;
    notifyListeners();
    _userData = userData;
    _isLoading = false;
    notifyListeners();
  }

  // Stub updateProfilePhoto for mock
  void updateProfilePhoto(String userId, String photoUrl) {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (_userData != null) {
      _userData = _userData!.copyWith(photoUrl: photoUrl);
    }
    _isLoading = false;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
