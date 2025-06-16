import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: true, // TODO: Bind to user preference
            onChanged: (value) {
              // TODO: Update notification preference
            },
          ),
          ListTile(
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: 'en', // TODO: Bind to user preference
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'es', child: Text('Spanish')),
                DropdownMenuItem(value: 'fr', child: Text('French')),
              ],
              onChanged: (value) {
                // TODO: Update language preference
              },
            ),
          ),
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<String>(
              value: 'light', // TODO: Bind to user preference
              items: const [
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
              ],
              onChanged: (value) {
                // TODO: Update theme preference
              },
            ),
          ),
        ],
      ),
    );
  }
} 