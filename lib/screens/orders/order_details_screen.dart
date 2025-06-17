import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../store/book_details_screen.dart';

/// A screen that displays detailed information about an order.
class OrderDetailsScreen extends StatelessWidget {
  /// The order to display details for.
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 8)}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OrderStatusCard(status: order.status),
            const SizedBox(height: 24),
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...order.items.map((item) => _OrderItemCard(item: item)),
            const SizedBox(height: 24),
            const Text(
              'Shipping Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Shipping Address',
              content: order.shippingAddress.toString(),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Payment Method',
              content: order.paymentMethod ?? 'Not specified',
            ),
            const SizedBox(height: 24),
            const Text(
              'Order Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Order Date',
              content: _formatDate(order.createdAt),
            ),
            const SizedBox(height: 8),
            _InfoCard(
              title: 'Order Number',
              content: order.id,
            ),
            const SizedBox(height: 24),
            _OrderSummaryCard(
              subtotal: order.subtotal,
              shipping: order.shippingCost ?? 0.0,
              tax: order.tax ?? 0.0,
              total: order.total,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute}';
  }
}

/// A widget that displays the status of an order.
class _OrderStatusCard extends StatelessWidget {
  final OrderStatus status;

  const _OrderStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        icon = Icons.pending;
        break;
      case OrderStatus.processing:
        color = Colors.blue;
        text = 'Processing';
        icon = Icons.sync;
        break;
      case OrderStatus.shipped:
        color = Colors.purple;
        text = 'Shipped';
        icon = Icons.local_shipping;
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        text = 'Delivered';
        icon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        icon = Icons.cancel;
        break;
    }

    return Card(
      color: color.withAlpha(25),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusDescription(status),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Your order is being processed';
      case OrderStatus.processing:
        return 'We are preparing your order';
      case OrderStatus.shipped:
        return 'Your order is on the way';
      case OrderStatus.delivered:
        return 'Your order has been delivered';
      case OrderStatus.cancelled:
        return 'Your order has been cancelled';
    }
  }
}

/// A widget that displays an item in an order.
class _OrderItemCard extends StatelessWidget {
  /// The order item to display.
  final OrderItem item;

  const _OrderItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Image.network(
          item.coverImage,
          width: 50,
          height: 75,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.book);
          },
        ),
        title: Text(item.title),
        subtitle: Text('Quantity: ${item.quantity}'),
        trailing: Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
        onTap: () {
          if (item.book != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailsScreen(book: item.book!),
              ),
            );
          }
        },
      ),
    );
  }
}

/// A widget that displays information about an order.
class _InfoCard extends StatelessWidget {
  /// The title of the information card.
  final String title;

  /// The content of the information card.
  final String content;

  const _InfoCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that displays a summary of an order.
class _OrderSummaryCard extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;

  const _OrderSummaryCard({
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _SummaryRow(
              label: 'Subtotal',
              value: subtotal,
            ),
            const Divider(),
            _SummaryRow(
              label: 'Shipping',
              value: shipping,
            ),
            const Divider(),
            _SummaryRow(
              label: 'Tax',
              value: tax,
            ),
            const Divider(),
            _SummaryRow(
              label: 'Total',
              value: total,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
