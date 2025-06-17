import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/address.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final ShippingAddress address;
  final double total;

  const PaymentScreen({
    super.key,
    required this.items,
    required this.address,
    required this.total,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // TODO: Integrate with actual payment gateway
      await Future.delayed(
          const Duration(seconds: 2)); // Simulate payment processing

      if (!mounted) return;

      await Provider.of<AppProvider>(context, listen: false).placeOrder(
        items: widget.items,
        address: widget.address,
        total: widget.total,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed('/order-success');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text('Total: \$${widget.total.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping Address',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(widget.address.toString()),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
