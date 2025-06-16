import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/order.dart' as model; 
import '../../widgets/loading_widget.dart';
import '../../widgets/order_card.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: true,
          title: const Text("My Orders"),
          backgroundColor: Colors.blueGrey,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection("orders")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: LoadingWidget());
            }

            final orderDocs = snapshot.data!.docs;

            if (orderDocs.isEmpty) {
              return const Center(child: Text("No orders found."));
            }

            return ListView.builder(
              itemCount: orderDocs.length,
              itemBuilder: (context, index) {
                final doc = orderDocs[index];
                final order = model.Order.fromFirestore(doc);

                return OrderCard(
                  order: order,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
