import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
// import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
// import '../mock_data.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  // final UserService _userService = UserService();

  // Mock user data for offline authentication
  static const List<Map<String, dynamic>> _mockUsers = [
    {
      'email': 'user@example.com',
      'password': 'password123',
      'uid': 'mock_user_001',
      'displayName': 'Demo User',
      'photoURL': null,
      'isAdmin': false,
    },
    {
      'email': 'admin@example.com',
      'password': 'admin123',
      'uid': 'mock_admin_001',
      'displayName': 'Admin User',
      'photoURL': null,
      'isAdmin': true,
    },
  ];

  // Stream controller for auth state changes
  final StreamController<Map<String, dynamic>?> _authStateController =
      StreamController<Map<String, dynamic>?>.broadcast();

  // Flag to determine if Firebase is available
  bool _isFirebaseAvailable = false;

  AuthService() {
    _checkFirebaseAvailability();
  }

  /// Checks if Firebase is properly configured and available
  Future<void> _checkFirebaseAvailability() async {
    try {
      // Try to access Firebase Auth to see if it's available
      await _auth.authStateChanges().first;
      _isFirebaseAvailable = true;
      debugPrint('Firebase Auth is available');

      // For demo purposes, we'll use mock authentication even when Firebase is available
      // This allows testing with demo credentials without setting up Firebase users
      _isFirebaseAvailable = false;
      debugPrint('Using mock authentication for demo purposes');
    } catch (e) {
      _isFirebaseAvailable = false;
      debugPrint('Firebase Auth not available, using mock authentication: $e');
    }
  }

  /// Returns a stream of authentication state changes.
  Stream<Map<String, dynamic>?> get onAuthStateChanged {
    if (_isFirebaseAvailable) {
      return _auth.authStateChanges().map((user) {
        if (user != null) {
          return {
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
          };
        }
        return null;
      });
    } else {
      return _authStateController.stream;
    }
  }

  /// Signs in a user with email and password.
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    if (_isFirebaseAvailable) {
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user;
        if (user != null) {
          return {
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
          };
        }
        throw Exception('Sign in failed');
      } catch (e) {
        throw Exception('Sign in failed: $e');
      }
    } else {
      // Mock authentication
      try {
        final mockUser = _mockUsers.firstWhere(
          (user) => user['email'] == email && user['password'] == password,
          orElse: () => throw Exception('Invalid email or password'),
        );

        final userData = {
          'uid': mockUser['uid'],
          'email': mockUser['email'],
          'displayName': mockUser['displayName'],
          'photoURL': mockUser['photoURL'],
        };

        _authStateController.add(userData);
        return userData;
      } catch (e) {
        throw Exception('Invalid email or password');
      }
    }
  }

  /// Signs up a new user with email and password.
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    if (_isFirebaseAvailable) {
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user;
        if (user != null) {
          // Create user document in Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'email': email,
            'createdAt': firestore.FieldValue.serverTimestamp(),
            'isAdmin': false,
          });

          return {
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
          };
        }
        throw Exception('Sign up failed');
      } catch (e) {
        throw Exception('Sign up failed: $e');
      }
    } else {
      // Mock sign up - check if user already exists
      if (_mockUsers.any((user) => user['email'] == email)) {
        throw Exception('User already exists');
      }

      // Create new mock user
      final newUser = {
        'email': email,
        'password': password,
        'uid': 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        'displayName': email.split('@')[0],
        'photoURL': null,
        'isAdmin': false,
      };

      // In a real implementation, you'd save this to local storage
      // For now, we'll just add it to the mock users list
      _mockUsers.add(newUser);

      final userData = {
        'uid': newUser['uid'],
        'email': newUser['email'],
        'displayName': newUser['displayName'],
        'photoURL': newUser['photoURL'],
      };

      _authStateController.add(userData);
      return userData;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    if (_isFirebaseAvailable) {
      try {
        await _auth.signOut();
      } catch (e) {
        throw Exception('Sign out failed: $e');
      }
    } else {
      // Mock sign out
      _authStateController.add(null);
    }
  }

  /// Resets the password for a user with the provided email.
  Future<void> resetPassword(String email) async {
    if (_isFirebaseAvailable) {
      try {
        await _auth.sendPasswordResetEmail(email: email);
      } catch (e) {
        throw Exception('Password reset failed: $e');
      }
    } else {
      // Mock password reset - just check if user exists
      if (!_mockUsers.any((user) => user['email'] == email)) {
        throw Exception('User not found');
      }
      // In a real implementation, you'd send an email
      // For mock purposes, we'll just return success
    }
  }

  /// Gets the current user.
  Map<String, dynamic>? get currentUser {
    if (_isFirebaseAvailable) {
      final user = _auth.currentUser;
      if (user != null) {
        return {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
        };
      }
      return null;
    } else {
      // For mock auth, we need to track the current user
      // This is a simplified implementation
      return null;
    }
  }

  /// Checks if the current user is an admin.
  Future<bool> isAdmin() async {
    if (_isFirebaseAvailable) {
      try {
        final user = _auth.currentUser;
        if (user == null) return false;

        final doc = await _firestore.collection('users').doc(user.uid).get();
        return doc.exists && (doc.data()?['isAdmin'] ?? false);
      } catch (e) {
        return false;
      }
    } else {
      // Mock admin check
      // This is a simplified implementation - in practice you'd need to track the current user
      return false;
    }
  }

  /// Updates the user's display name.
  Future<void> updateDisplayName(String displayName) async {
    if (_isFirebaseAvailable) {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await user.updateDisplayName(displayName);
          await _firestore.collection('users').doc(user.uid).update({
            'displayName': displayName,
          });
        }
      } catch (e) {
        throw Exception('Failed to update display name: $e');
      }
    } else {
      // Mock update - would update local storage in real implementation
      throw Exception('Display name update not implemented in mock mode');
    }
  }

  /// Updates the user's photo URL.
  Future<void> updatePhotoURL(String photoURL) async {
    if (_isFirebaseAvailable) {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await user.updatePhotoURL(photoURL);
          await _firestore.collection('users').doc(user.uid).update({
            'photoURL': photoURL,
          });
        }
      } catch (e) {
        throw Exception('Failed to update photo URL: $e');
      }
    } else {
      // Mock update - would update local storage in real implementation
      throw Exception('Photo URL update not implemented in mock mode');
    }
  }

  /// Deletes the current user account.
  Future<void> deleteAccount() async {
    if (_isFirebaseAvailable) {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).delete();
          await user.delete();
        }
      } catch (e) {
        throw Exception('Failed to delete account: $e');
      }
    } else {
      // Mock account deletion
      _authStateController.add(null);
    }
  }

  /// Disposes the service
  void dispose() {
    _authStateController.close();
  }

  // Sign in with Google
  /*
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in aborted');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Create or update user profile
      if (userCredential.user != null) {
        await _userService.updateUserProfile(
          userId: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? '',
          email: userCredential.user!.email!,
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  */

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Wrong password provided.');
      case 'email-already-in-use':
        return Exception('Email is already in use.');
      case 'invalid-email':
        return Exception('Email address is invalid.');
      case 'weak-password':
        return Exception('Password is too weak.');
      case 'operation-not-allowed':
        return Exception('Operation not allowed.');
      case 'user-disabled':
        return Exception('User has been disabled.');
      default:
        return Exception(e.message ?? 'An error occurred.');
    }
  }

  Future<void> updateUserProfile(
      {String? userId,
      String? name,
      String? email,
      String? photoUrl,
      String? address}) async {
    // No-op for mock
  }
}
