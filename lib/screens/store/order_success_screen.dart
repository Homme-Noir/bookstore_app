import 'package:flutter/material.dart';
import '../../widgets/wide_button.dart';
import '../../theme/app_theme.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Success'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(height: 32),

              // Success Message
              Text(
                'Order Placed Successfully!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                'Thank you for your purchase. Your order has been confirmed and will be processed soon.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Action Buttons
              WideButton(
                text: 'Continue Shopping',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
                backgroundColor: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),

              WideButton(
                text: 'View Orders',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/orders');
                },
                backgroundColor: AppTheme.secondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
