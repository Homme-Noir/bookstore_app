import 'db_helper.dart';
import '../models/book.dart';
import 'package:sqflite/sqflite.dart';

class WishlistService {
  final DBHelper _dbHelper = DBHelper();

  Future<List<String>> getWishlistBookIds(String userId) async {
    final db = await _dbHelper.db;
    final result =
        await db.query('wishlist', where: 'userId = ?', whereArgs: [userId]);
    return result.map((e) => e['bookId'] as String).toList();
  }

  Future<void> addToWishlist(String userId, String bookId) async {
    final db = await _dbHelper.db;
    await db.insert('wishlist', {'userId': userId, 'bookId': bookId},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFromWishlist(String userId, String bookId) async {
    final db = await _dbHelper.db;
    await db.delete('wishlist',
        where: 'userId = ? AND bookId = ?', whereArgs: [userId, bookId]);
  }

  Future<List<Book>> getWishlist(String userId) async {
    final bookIds = await getWishlistBookIds(userId);
    // You may want to fetch books from BookService using these IDs
    // For now, just return empty list or implement as needed
    return [];
  }
}
