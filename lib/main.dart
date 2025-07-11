import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/library_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/store_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/open_library_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://alzdwsarjfdpnidlczwv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsemR3c2FyamZkcG5pZGxjend2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE1OTAxNzEsImV4cCI6MjA2NzE2NjE3MX0.RCwZGoB_Jvx1PZpRuPvApdCnQQ1op3qIuyJuF7UT-c0',
  );
  runApp(const MyApp());
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final openLibraryService = OpenLibraryService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppProvider(
            authService: authService,
            openLibraryService: openLibraryService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'Book Store',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/register_screen': (context) => const RegisterScreen(),
          '/forgot_password_screen': (context) => const ForgotPasswordScreen(),
          '/login': (context) => const LoginScreen(),
          '/store': (context) => const StoreScreen(),
          '/library': (context) => const LibraryScreen(),
          '/cart': (context) => const CartScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/admin': (context) => const AdminDashboardScreen(),
        },
      ),
    );
  }
}
