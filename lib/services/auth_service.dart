import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/resolved_runtime_config.dart';
import '../core/security/secure_kv_store.dart';

/// Authentication: Supabase Auth when configured, otherwise in-memory mock users.
///
/// Listens to Supabase session changes when initialized; mock mode is intended
/// for local development without backend credentials.
class AuthService {
  static final List<Map<String, dynamic>> _mockUsers = [
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

  final StreamController<Map<String, dynamic>?> _authStateController =
      StreamController<Map<String, dynamic>?>.broadcast();

  bool _isSupabaseConfigured = false;
  StreamSubscription<AuthState>? _authSubscription;
  Map<String, dynamic>? _mockCurrentUser;
  final SecureKvStore _secureStore;

  AuthService({SecureKvStore? secureStore})
      : _secureStore = secureStore ?? const SecureKvStore() {
    _initializeSupabase();
  }

  Future<void> _initializeSupabase() async {
    final cfg = ResolvedRuntimeConfig.instance;
    if (!cfg.isSupabaseConfigured) {
      _isSupabaseConfigured = false;
      debugPrint(
        'Supabase env missing; using mock authentication. '
        'Set SUPABASE_URL and SUPABASE_ANON_KEY in .env.local, or use '
        '--dart-define / --dart-define-from-file.',
      );
      return;
    }

    try {
      final client = Supabase.instance.client;
      _isSupabaseConfigured = true;

      _authSubscription = client.auth.onAuthStateChange.listen((event) {
        final user = event.session?.user;
        final mapped = user == null ? null : _mapSupabaseUser(user);
        if (mapped == null) {
          _clearAuthMeta();
        } else {
          _persistAuthMeta(mapped);
        }
        _authStateController.add(mapped);
      });

      final current = client.auth.currentUser;
      if (current != null) {
        _authStateController.add(_mapSupabaseUser(current));
      }
    } catch (e) {
      _isSupabaseConfigured = false;
      debugPrint('Supabase unavailable; using mock authentication: $e');
    }
  }

  Stream<Map<String, dynamic>?> get onAuthStateChanged {
    return _authStateController.stream;
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    if (_isSupabaseConfigured) {
      try {
        final result = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        final user = result.user;
        if (user == null) {
          throw Exception('No user in session');
        }
        final userData = _mapSupabaseUser(user);
        await _persistAuthMeta(userData);
        _authStateController.add(userData);
        return userData;
      } on AuthException catch (e) {
        debugPrint(
          'Supabase signInWithPassword: ${e.message} code=${e.code}',
        );
        throw Exception(_signInErrorMessage(e));
      } catch (e, st) {
        debugPrint('signIn unexpected: $e\n$st');
        throw Exception('Sign in failed: $e');
      }
    }

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
    _mockCurrentUser = userData;
    await _persistAuthMeta(userData);
    _authStateController.add(userData);
    return userData;
  }

  Future<Map<String, dynamic>> signUp(String email, String password) async {
    if (_isSupabaseConfigured) {
      try {
        final result = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        final user = result.user;
        if (user != null) {
          final userData = _mapSupabaseUser(user);
          await _persistAuthMeta(userData);
          _authStateController.add(userData);
          return userData;
        }
        return signIn(email, password);
      } on AuthException catch (e) {
        debugPrint('Supabase signUp: ${e.message} code=${e.code}');
        throw Exception(_signInErrorMessage(e));
      } catch (e, st) {
        debugPrint('signUp unexpected: $e\n$st');
        throw Exception('Sign up failed: $e');
      }
    }

    if (_mockUsers.any((user) => user['email'] == email)) {
      throw Exception('User already exists');
    }

    final newUser = {
      'email': email,
      'password': password,
      'uid': 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      'displayName': email.split('@')[0],
      'photoURL': null,
      'isAdmin': false,
    };
    _mockUsers.add(newUser);

    final userData = {
      'uid': newUser['uid'],
      'email': newUser['email'],
      'displayName': newUser['displayName'],
      'photoURL': newUser['photoURL'],
    };
    _mockCurrentUser = userData;
    await _persistAuthMeta(userData);
    _authStateController.add(userData);
    return userData;
  }

  Future<void> signOut() async {
    if (_isSupabaseConfigured) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {
        throw Exception('Sign out failed');
      }
    }
    _mockCurrentUser = null;
    await _clearAuthMeta();
    _authStateController.add(null);
  }

  Future<void> resetPassword(String email) async {
    if (_isSupabaseConfigured) {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      return;
    }
    if (!_mockUsers.any((user) => user['email'] == email)) {
      throw Exception('User not found');
    }
  }

  Map<String, dynamic>? get currentUser {
    if (!_isSupabaseConfigured) {
      return _mockCurrentUser;
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return null;
    }
    return _mapSupabaseUser(user);
  }

  Future<bool> isAdmin() async {
    final email = currentUser?['email']?.toString().toLowerCase();
    return email == 'admin@example.com';
  }

  Future<void> updateDisplayName(String displayName) async {
    if (_isSupabaseConfigured) {
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'display_name': displayName}),
        );
      } catch (_) {
        throw Exception('Failed to update display name');
      }
      return;
    }
    _mockCurrentUser = {
      ...?_mockCurrentUser,
      'displayName': displayName,
    };
    _authStateController.add(_mockCurrentUser);
  }

  Future<void> updatePhotoURL(String photoURL) async {
    _mockCurrentUser = {
      ...?_mockCurrentUser,
      'photoURL': photoURL,
    };
    _authStateController.add(_mockCurrentUser);
  }

  Future<void> deleteAccount() async {
    if (_isSupabaseConfigured) {
      throw Exception(
        'Account deletion should be handled by a secured Supabase function.',
      );
    }
    _mockCurrentUser = null;
    _authStateController.add(null);
  }

  void dispose() {
    _authSubscription?.cancel();
    _authStateController.close();
  }

  Future<void> updatePassword(String newPassword) async {
    if (_isSupabaseConfigured) {
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: newPassword),
        );
      } catch (_) {
        throw Exception('Failed to update password');
      }
      return;
    }
    throw Exception('Password update not implemented in mock mode');
  }

  /// Maps GoTrue / Supabase Auth errors to short UI copy. Table data alone does
  /// not create an [auth.users] row — users must exist under Authentication.
  static String _signInErrorMessage(AuthException e) {
    final code = e.code?.toLowerCase();
    final msg = e.message;
    if (code == 'email_not_confirmed' ||
        msg.toLowerCase().contains('email not confirmed')) {
      return 'Confirm your email: open the link Supabase sent, or disable '
          '“Confirm email” in Dashboard → Authentication → Providers → Email '
          '(dev only).';
    }
    if (code == 'invalid_credentials' ||
        msg.toLowerCase().contains('invalid login')) {
      return 'Invalid email or password. If you only added data in the Table '
          'Editor, create a user under Authentication → Users (or sign up in the app).';
    }
    if (msg.isNotEmpty) return msg;
    return 'Sign in failed';
  }

  Map<String, dynamic> _mapSupabaseUser(User user) {
    return {
      'uid': user.id,
      'email': user.email,
      'displayName': user.userMetadata?['display_name'] ?? user.email,
      'photoURL': null,
    };
  }

  Future<void> updateUserProfile(
      {String? userId,
      String? name,
      String? email,
      String? photoUrl,
      String? address}) async {
    // No-op for mock
  }

  Future<void> _persistAuthMeta(Map<String, dynamic> user) async {
    await _secureStore.write('session_user_id', user['uid']?.toString() ?? '');
    await _secureStore.write(
      'session_user_email',
      user['email']?.toString() ?? '',
    );
  }

  Future<void> _clearAuthMeta() async {
    await _secureStore.delete('session_user_id');
    await _secureStore.delete('session_user_email');
  }
}
