import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

/// A screen that displays the user's profile information and allows for profile updates.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _signOut() async {
    try {
      await Provider.of<AppProvider>(context, listen: false).signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final userId = provider.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(),
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: Text('Not logged in'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                const Text(
                  'User',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'user@example.com',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: const Text('Orders'),
                  onTap: () {
                    Navigator.pushNamed(context, '/orders');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('Wishlist'),
                  onTap: () {
                    Navigator.pushNamed(context, '/wishlist');
                  },
                ),
              ],
            ),
    );
  }
}
