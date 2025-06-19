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

  Future<void> _mockProcessPayment() async {
    setState(() {
      _isProcessing = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await Provider.of<AppProvider>(context, listen: false).placeOrder(
      items: widget.items,
      address: widget.address,
      total: widget.total,
    );
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });
    Navigator.of(context).pushReplacementNamed('/order-success');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: SingleChildScrollView(
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () async {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Payment'),
                          content: const Text('Proceed with mock payment?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                      );
                      if (mounted && !_isProcessing) {
                        await _mockProcessPayment();
                      }
                    },
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
