import 'dart:convert';
import 'db_helper.dart';
import '../models/order.dart' as model;
import '../models/address.dart';

class OrderService {
  final DBHelper _dbHelper = DBHelper();

  Future<List<model.Order>> getOrders(String userId) async {
    final db = await _dbHelper.db;
    final result =
        await db.query('orders', where: 'userId = ?', whereArgs: [userId]);
    return result.map((e) => model.Order.fromMap(e)).toList();
  }

  Future<void> placeOrder(model.Order order) async {
    final db = await _dbHelper.db;
    await db.insert('orders', order.toMap());
  }

  Future<model.Order?> getOrder(String orderId) async {
    final db = await _dbHelper.db;
    final result =
        await db.query('orders', where: 'id = ?', whereArgs: [orderId]);
    if (result.isNotEmpty) {
      return model.Order.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateOrderStatus(
      String orderId, model.OrderStatus status) async {
    final db = await _dbHelper.db;
    await db.update('orders', {'status': status.toString().split('.').last},
        where: 'id = ?', whereArgs: [orderId]);
  }
}
