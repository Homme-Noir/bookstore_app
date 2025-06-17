import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/user_provider.dart';
import 'models/order.dart';
import 'models/address.dart';
import 'screens/splash_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/book_management_screen.dart';
import 'screens/admin/book_edit_screen.dart';
import 'screens/admin/category_management_screen.dart';
import 'screens/admin/order_management_screen.dart';
import 'screens/wishlist/wishlist_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/orders/order_history_screen.dart';
import 'screens/orders/order_details_screen.dart';
import 'screens/payment/payment_screen.dart';
import 'services/auth_service.dart';
import 'services/book_service.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'services/user_service.dart';
import 'firebase_options/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
    runApp(const FirebaseInitErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreInstance = firestore.FirebaseFirestore.instance;
    final authService = AuthService();
    final userService = UserService();
    final cartService = CartService();
    final bookService = BookService();
    final orderService = OrderService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppProvider(
            authService: authService,
            bookService: bookService,
            cartService: cartService,
            orderService: orderService,
            userService: userService,
            firestore: firestoreInstance,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            userService: userService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BookProvider(bookService: bookService),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(cartService: cartService),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(orderService: orderService),
        ),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider(userService: userService),
        ),
      ],
      child: MaterialApp(
        title: 'Book Store',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/admin': (context) => const AdminDashboard(),
          '/admin/books': (context) => const BookManagementScreen(),
          '/admin/book-edit': (context) => const BookEditScreen(),
          '/admin/categories': (context) => const CategoryManagementScreen(),
          '/admin/orders': (context) => const OrderManagementScreen(),
          '/wishlist': (context) => const WishlistScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/orders': (context) => const OrderHistoryScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/order-details') {
            final order = settings.arguments as Order;
            return MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(
                order: order,
              ),
            );
          }
          if (settings.name == '/payment') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => PaymentScreen(
                items: args['items'] as List<Map<String, dynamic>>,
                address: args['address'] as ShippingAddress,
                total: args['total'] as double,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

class FirebaseInitErrorApp extends StatelessWidget {
  const FirebaseInitErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'Error initializing Firebase.\nPlease check your configuration.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      ),
    );
  }
}