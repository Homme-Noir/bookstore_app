import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists light / dark / system appearance (Readest-style reading app chrome).
class ThemeController extends ChangeNotifier {
  ThemeController() {
    Future<void>.microtask(_restore);
  }

  static const _prefsKey = 'app_theme_mode';

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get themeMode => _mode;

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      _mode = ThemeMode.values.firstWhere(
        (m) => m.name == stored,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}
