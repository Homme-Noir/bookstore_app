import 'db_helper.dart';
import '../models/user_data.dart';
import '../models/address.dart';

class UserService {
  final DBHelper _dbHelper = DBHelper();

  Future<UserData?> getUserData(String userId) async {
    final db = await _dbHelper.db;
    final result =
        await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (result.isNotEmpty) {
      return UserData.fromMap(result.first);
    }
    return null;
  }

  Future<void> createUserData(UserData userData, {String? password}) async {
    final db = await _dbHelper.db;
    await db.insert('users', {
      ...userData.toMap(),
      if (password != null) 'password': password,
    });
  }

  Future<void> updateUserData(UserData userData) async {
    final db = await _dbHelper.db;
    await db.update('users', userData.toMap(),
        where: 'id = ?', whereArgs: [userData.id]);
  }

  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? photoUrl,
    String? address,
  }) async {
    final db = await _dbHelper.db;
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    // For address, you may want to update a separate addresses table or a JSON field
    await db.update('users', updates, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> updateProfilePhoto(String userId, String photoUrl) async {
    final db = await _dbHelper.db;
    await db.update('users', {'photoUrl': photoUrl},
        where: 'id = ?', whereArgs: [userId]);
  }

  Future<bool> isAdmin(String userId) async {
    final db = await _dbHelper.db;
    final result =
        await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (result.isNotEmpty) {
      return (result.first['isAdmin'] ?? 0) == 1;
    }
    return false;
  }
}
