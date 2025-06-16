import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/order.dart';

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: StreamBuilder<List<Order>>(
        stream: context.read<AppProvider>().getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('No orders found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('Order #${order.id.substring(0, 8)}'),
                  subtitle: Text('Status: ${order.status.name}\nTotal: \\$${order.total.toStringAsFixed(2)}'),
                  trailing: PopupMenuButton<OrderStatus>(
                    icon: const Icon(Icons.edit),
                    onSelected: (status) {
                      context.read<AppProvider>().updateOrderStatus(order.id, status);
                    },
                    itemBuilder: (context) => OrderStatus.values
                        .map((status) => PopupMenuItem(
                              value: status,
                              child: Text(status.name),
                            ))
                        .toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 