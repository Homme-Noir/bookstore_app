import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;
  UserData? _userData;
  bool _isLoading = false;
  String? _error;

  UserProvider({
    required UserService userService,
  }) : _userService = userService;

  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load user data
  Future<void> loadUserData(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userData = await _userService.getUserData(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user data
  Future<void> updateUserData(UserData userData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userService.updateUserData(userData);
      _userData = userData;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile photo
  Future<void> updateProfilePhoto(String userId, String photoUrl) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userService.updateProfilePhoto(userId, photoUrl);
      if (_userData != null) {
        _userData = _userData!.copyWith(photoUrl: photoUrl);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
