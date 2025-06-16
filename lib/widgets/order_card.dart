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
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(int.parse(_getStatusColor(order.status)
                          .replaceAll('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${DateFormat('MMM dd, yyyy').format(order.createdAt)}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: \$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusColor(model.OrderStatus status) {
    switch (status) {
      case model.OrderStatus.pending:
        return '#FFA500';
      case model.OrderStatus.processing:
        return '#1E90FF';
      case model.OrderStatus.shipped:
        return '#32CD32';
      case model.OrderStatus.delivered:
        return '#008000';
      case model.OrderStatus.cancelled:
        return '#FF0000';
      default:
        return '#808080';
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
              SizedBox(height: 15),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      model.title,
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CircleAvatar(radius: 3, backgroundColor: background),
                  SizedBox(width: 5),
                  Text(
                    model.pageCount.toString(),
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
