import 'package:flutter/material.dart';
import '../../widgets/order_card.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppProvider>().orders;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: true,
          title: const Text("My Orders"),
          backgroundColor: Colors.blueGrey,
        ),
        body: orders.isEmpty
            ? const Center(child: Text("No orders found."))
            : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return OrderCard(order: order);
                },
              ),
      ),
    );
  }
}
