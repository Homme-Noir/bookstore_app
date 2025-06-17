import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _notificationsEnabled = true;
  String _language = 'en';
  String _theme = 'light';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
      _language = _prefs.getString('language') ?? 'en';
      _theme = _prefs.getString('theme') ?? 'light';
    });
  }

  Future<void> _updateNotificationPreference(bool value) async {
    await _prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _updateLanguagePreference(String? value) async {
    if (value == null) return;
    await _prefs.setString('language', value);
    setState(() {
      _language = value;
    });
  }

  Future<void> _updateThemePreference(String? value) async {
    if (value == null) return;
    await _prefs.setString('theme', value);
    if (!mounted) return;
    setState(() {
      _theme = value;
    });
    // Update app theme
    final appProvider = context.read<AppProvider>();
    appProvider.setTheme(value == 'dark' ? ThemeMode.dark : ThemeMode.light);
  }

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
            value: _notificationsEnabled,
            onChanged: _updateNotificationPreference,
          ),
          ListTile(
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: _language,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'es', child: Text('Spanish')),
                DropdownMenuItem(value: 'fr', child: Text('French')),
              ],
              onChanged: _updateLanguagePreference,
            ),
          ),
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<String>(
              value: _theme,
              items: const [
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
              ],
              onChanged: _updateThemePreference,
            ),
          ),
        ],
      ),
    );
  }
}
