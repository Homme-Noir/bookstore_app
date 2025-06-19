import 'package:sqflite/sqflite.dart';
import 'db_helper.dart';
import '../models/user_data.dart';
import 'package:path/path.dart';
import 'dart:math';

class AuthService {
  final DBHelper _dbHelper = DBHelper();

  // Sign in with email and password
  Future<UserData?> signIn(String email, String password) async {
    final db = await _dbHelper.db;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return UserData.fromMap(result.first);
    }
    return null;
  }

  // Register with email, password, and name
  Future<UserData> signUp(String email, String password, String name) async {
    final db = await _dbHelper.db;
    final id = _generateId();
    final user = UserData(
      id: id,
      email: email,
      name: name,
      photoUrl: null,
    );
    await db.insert('users', {
      ...user.toMap(),
      'password': password,
    });
    return user;
  }

  // Sign out (no-op for SQLite)
  Future<void> signOut() async {
    // No persistent session for SQLite
  }

  // Reset password (not implemented for SQLite)
  Future<void> resetPassword(String email) async {
    // Implement as needed
  }

  // Helper to generate a random user ID
  String _generateId() {
    final rand = Random();
    return List.generate(16, (_) => rand.nextInt(10)).join();
  }
}
