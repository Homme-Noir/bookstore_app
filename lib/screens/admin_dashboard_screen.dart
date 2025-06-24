import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'User Overview'),
              Tab(text: 'Analytics'),
            ],
            indicatorColor: Colors.white,
            indicatorWeight: 4.0,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: const TabBarView(
          children: [
            _UserOverviewTab(),
            _AnalyticsTab(),
          ],
        ),
      ),
    );
  }
}

class _UserOverviewTab extends StatelessWidget {
  const _UserOverviewTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final orderHistory = profileProvider.orderHistory;
        final email = profileProvider.email;
        final totalOrders = orderHistory.length;
        final totalSpent = orderHistory.fold<double>(
            0, (sum, order) => sum + order.totalAmount);
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ListTile(
              leading: const Icon(Icons.person, size: 40),
              title: Text(email.isNotEmpty ? email : 'User'),
              subtitle: Text(
                  'Orders: $totalOrders\nTotal Spent: \$${totalSpent.toStringAsFixed(2)}'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            Text('Order History',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (orderHistory.isEmpty) const Text('No orders yet.'),
            ...orderHistory.map((order) => Card(
                  child: ListTile(
                    title: Text(
                        'Order #${order.id.substring(order.id.length - 8)}'),
                    subtitle: Text(
                        'Total: \$${order.totalAmount.toStringAsFixed(2)}\nDate: ${order.orderDate}'),
                  ),
                )),
          ],
        );
      },
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final orderHistory = profileProvider.orderHistory;
        final totalOrders = orderHistory.length;
        final totalSales = orderHistory.fold<double>(
            0, (sum, order) => sum + order.totalAmount);
        // Count most popular books
        final Map<String, int> bookCounts = {};
        for (final order in orderHistory) {
          for (final book in order.books) {
            bookCounts[book.title] = (bookCounts[book.title] ?? 0) + 1;
          }
        }
        final popularBooks = bookCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Total Orders: $totalOrders',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Total Sales: \$${totalSales.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Text('Most Popular Books',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (popularBooks.isEmpty) const Text('No sales yet.'),
            ...popularBooks.take(5).map((entry) => ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(entry.key),
                  trailing: Text('Sold: ${entry.value}'),
                )),
          ],
        );
      },
    );
  }
}
