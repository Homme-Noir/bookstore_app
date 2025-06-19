import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_service.dart';
import 'dart:async';
import '../mock_data.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();

  static final _mockUser = {'uid': 'user_001', 'email': 'john.doe@example.com'};
  static final _authStateController =
      StreamController<Map<String, String>?>.broadcast();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<Map<String, String>?> get onAuthStateChanged =>
      _authStateController.stream;

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    // Find the mock user by email
    final user = MockData.users.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('No user found with this email.'),
    );
    _authStateController.add({'uid': user.id, 'email': user.email});
  }

  // Register with email and password
  Future<Map<String, String>> signUp(String email, String password) async {
    // Find the mock user by email
    final user = MockData.users.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('No user found with this email.'),
    );
    _authStateController.add({'uid': user.id, 'email': user.email});
    return {'uid': user.id, 'email': user.email};
  }

  // Sign in with Google
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

  // Sign out
  Future<void> signOut() async {
    _authStateController.add(null);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

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
