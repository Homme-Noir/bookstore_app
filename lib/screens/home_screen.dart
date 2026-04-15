import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/app_provider.dart';
import 'auth/login_screen.dart';
import 'library_shell_screen.dart';
import 'onboarding_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<bool> _isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOnboardingComplete(),
      builder: (context, onboardingSnapshot) {
        if (!onboardingSnapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (onboardingSnapshot.data == false) {
          return OnboardingScreen(
            onComplete: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          );
        }
        return Consumer<AppProvider>(
          builder: (context, appProvider, _) {
            if (appProvider.isAuthenticated) {
              return const LibraryShellScreen();
            }
            return const LoginScreen();
          },
        );
      },
    );
  }
}
