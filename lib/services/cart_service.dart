import 'db_helper.dart';
import '../models/cart_item.dart';
import '../models/book.dart';
import 'package:sqflite/sqflite.dart';

class CartService {
  final DBHelper _dbHelper = DBHelper();

  Future<List<CartItem>> getCartItems(String userId) async {
    final db = await _dbHelper.db;
    final result =
        await db.query('cart', where: 'userId = ?', whereArgs: [userId]);
    return result.map((e) => CartItem.fromMap(e)).toList();
  }

  Future<void> addToCart(String userId, CartItem item) async {
    final db = await _dbHelper.db;
    await db.insert(
        'cart',
        {
          ...item.toMap(),
          'userId': userId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateQuantity(
      String userId, String bookId, int quantity) async {
    final db = await _dbHelper.db;
    await db.update('cart', {'quantity': quantity},
        where: 'userId = ? AND bookId = ?', whereArgs: [userId, bookId]);
  }

  Future<void> removeFromCart(String userId, String bookId) async {
    final db = await _dbHelper.db;
    await db.delete('cart',
        where: 'userId = ? AND bookId = ?', whereArgs: [userId, bookId]);
  }

  Future<void> clearCart(String userId) async {
    final db = await _dbHelper.db;
    await db.delete('cart', where: 'userId = ?', whereArgs: [userId]);
  }
}
