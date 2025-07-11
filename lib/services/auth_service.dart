import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Returns a stream of authentication state changes.
  Stream<AuthState> get onAuthStateChanged {
    return _supabase.auth.onAuthStateChange;
  }

  /// Gets the current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Gets the current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Signs in a user with email and password.
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Sign in failed: No user returned');
      }

      return response;
    } on AuthException catch (e) {
      throw AuthException('Sign in failed: ${e.message}');
    } catch (e) {
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  /// Signs up a new user with email and password.
  Future<AuthResponse> signUp(String email, String password,
      {String? fullName}) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user == null) {
        throw AuthException('Sign up failed: No user returned');
      }

      return response;
    } on AuthException catch (e) {
      throw AuthException('Sign up failed: ${e.message}');
    } catch (e) {
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  /// Resets the password for a user with the provided email.
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthException('Password reset failed: ${e.message}');
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  /// Checks if the current user is an admin by querying the profiles table.
  Future<bool> isAdmin() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('profiles')
          .select('is_admin')
          .eq('id', user.id)
          .single();

      return response['is_admin'] ?? false;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  /// Updates the user's display name.
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthException('No user logged in');
      }

      await _supabase.auth.updateUser(
        UserAttributes(data: {'full_name': displayName}),
      );
    } on AuthException catch (e) {
      throw AuthException('Failed to update display name: ${e.message}');
    } catch (e) {
      throw AuthException('Failed to update display name: ${e.toString()}');
    }
  }

  /// Updates the user's photo URL.
  Future<void> updatePhotoURL(String photoURL) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthException('No user logged in');
      }

      await _supabase.auth.updateUser(
        UserAttributes(data: {'avatar_url': photoURL}),
      );
    } on AuthException catch (e) {
      throw AuthException('Failed to update photo URL: ${e.message}');
    } catch (e) {
      throw AuthException('Failed to update photo URL: ${e.toString()}');
    }
  }

  /// Updates the user's password.
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthException('No user logged in');
      }

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw AuthException('Failed to update password: ${e.message}');
    } catch (e) {
      throw AuthException('Failed to update password: ${e.toString()}');
    }
  }

  /// Creates or updates user profile in the profiles table.
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? photoUrl,
    String? address,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['full_name'] = name;
      if (email != null) data['email'] = email;
      if (photoUrl != null) data['avatar_url'] = photoUrl;
      if (address != null) data['address'] = address;

      await _supabase.from('profiles').upsert({
        'id': userId,
        ...data,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AuthException('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Gets user profile from the profiles table.
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('profiles').select().eq('id', userId).single();

      return response;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  /// Deletes the current user account.
  Future<void> deleteAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthException('No user logged in');
      }

      // First, delete user data from profiles table
      await _supabase.from('profiles').delete().eq('id', user.id);

      // Then sign out (Supabase handles user deletion on the backend)
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthException('Failed to delete account: ${e.toString()}');
    }
  }

  /// Signs in with OAuth provider (Google, GitHub, etc.)
  Future<void> signInWithOAuth(OAuthProvider provider) async {
    try {
      await _supabase.auth.signInWithOAuth(provider);
    } on AuthException catch (e) {
      throw AuthException('OAuth sign in failed: ${e.message}');
    } catch (e) {
      throw AuthException('OAuth sign in failed: ${e.toString()}');
    }
  }

  /// Signs in with OTP (One-Time Password)
  Future<void> signInWithOtp(String email) async {
    try {
      await _supabase.auth.signInWithOtp(email: email);
    } on AuthException catch (e) {
      throw AuthException('OTP sign in failed: ${e.message}');
    } catch (e) {
      throw AuthException('OTP sign in failed: ${e.toString()}');
    }
  }

  /// Verifies OTP and signs in the user
  Future<AuthResponse> verifyOtp(
      String email, String token, OtpType type) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: type,
      );

      return response;
    } on AuthException catch (e) {
      throw AuthException('OTP verification failed: ${e.message}');
    } catch (e) {
      throw AuthException('OTP verification failed: ${e.toString()}');
    }
  }
}
