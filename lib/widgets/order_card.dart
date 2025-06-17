import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/order.dart' as model;
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final model.Order order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM dd, yyyy').format(order.createdAt),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(model.OrderStatus status) {
    switch (status) {
      case model.OrderStatus.pending:
        return Colors.orange;
      case model.OrderStatus.processing:
        return Colors.blue;
      case model.OrderStatus.shipped:
        return Colors.purple;
      case model.OrderStatus.delivered:
        return Colors.green;
      case model.OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(model.OrderStatus status) {
    return status.toString().split('.').last;
  }
}

Widget sourceInfo(
  BookModel model,
  BuildContext context, {
  required Color background,
}) {
  final double width = MediaQuery.of(context).size.width;
  return SizedBox(
    height: 170,
    width: width - 20,
    child: Row(
      children: <Widget>[
        AspectRatio(
          aspectRatio: .7,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: background.withAlpha(25),
              image: DecorationImage(
                image: NetworkImage(model.thumbnailUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 15),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      model.title,
                      style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CircleAvatar(radius: 3, backgroundColor: background),
                  const SizedBox(width: 5),
                  Text(
                    model.pageCount.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
