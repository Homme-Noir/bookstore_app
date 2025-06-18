# Book Store App - Developer Guide

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Setup and Installation](#setup-and-installation)
4. [Project Structure](#project-structure)
5. [Key Components](#key-components)
6. [State Management](#state-management)
7. [Firebase Integration](#firebase-integration)
8. [Stripe Payment Integration](#stripe-payment-integration)
9. [Google Sign-In Integration](#google-sign-in-integration)
10. [Testing](#testing)
11. [Deployment](#deployment)
12. [Best Practices](#best-practices)
13. [Troubleshooting](#troubleshooting)

## Project Overview

The Book Store app is a Flutter-based e-commerce application that allows users to browse, purchase, and manage books. The app uses Firebase for backend services, Stripe for payments, and follows a clean architecture pattern.

### Tech Stack
- **Frontend**: Flutter 3.2.3+ (Dart)
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider
- **Payment Processing**: Stripe
- **Authentication**: Firebase Auth + Google Sign-In
- **UI**: Material Design with Google Fonts
- **Image Handling**: Image Picker
- **Local Storage**: Shared Preferences
- **Logging**: Logger
- **HTTP Client**: HTTP package

## Architecture

### Clean Architecture
The app follows clean architecture principles with the following layers:
- **Presentation Layer**: UI screens and widgets
- **Domain Layer**: Business logic and services
- **Data Layer**: Repository implementation and Firebase integration

### Directory Structure
```
lib/
├── models/              # Data models
│   ├── book.dart        # Book entity
│   ├── user_data.dart   # User profile
│   ├── order.dart       # Order entity
│   ├── cart_item.dart   # Shopping cart item
│   ├── address.dart     # Address entity
│   └── review.dart      # Review entity
├── screens/             # UI screens organized by feature
│   ├── auth/            # Authentication screens
│   ├── admin/           # Admin panel screens
│   ├── home/            # Home and navigation
│   ├── store/           # Book store and shopping
│   ├── profile/         # User profile management
│   ├── payment/         # Payment processing
│   ├── orders/          # Order management
│   └── wishlist/        # Wishlist functionality
├── services/            # Business logic and API calls
│   ├── auth_service.dart
│   ├── book_service.dart
│   ├── order_service.dart
│   ├── user_service.dart
│   ├── cart_service.dart
│   ├── wishlist_service.dart
│   └── review_service.dart
├── providers/           # State management
├── widgets/             # Reusable UI components
├── theme/               # App theming and styling
├── dialogs/             # Custom dialogs
└── firebase_options/    # Firebase configuration
```

## Setup and Installation

### Prerequisites
- Flutter SDK (3.2.3 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Stripe account (for payments)
- Git

### Environment Setup
1. **Clone the repository**:
   ```bash
   git clone https://github.com/Homme-Noir/bookstore_app.git
   cd bookstore_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Create a new Firebase project
   - Add Android and iOS apps
   - Download and add configuration files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`
   - Enable required Firebase services:
     - Authentication (Email/Password, Google)
     - Firestore Database
     - Storage

4. **Configure Stripe**:
   - Create a Stripe account
   - Get your publishable key
   - Add to app configuration

5. **Run the app**:
   ```bash
   flutter run
   ```

## Project Structure

### Models
```dart
// Book model
class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
}

// User model
class UserData {
  final String uid;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final List<Address> addresses;
  final bool isAdmin;
}

// Order model
class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;
  final Address shippingAddress;
  final String? trackingNumber;
}
```

### Services
```dart
// Authentication Service
class AuthService {
  Future<User?> signIn(String email, String password);
  Future<User?> signInWithGoogle();
  Future<User?> register(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
}

// Book Service
class BookService {
  Future<List<Book>> getBooks();
  Future<Book> getBookById(String id);
  Future<List<Book>> searchBooks(String query);
  Future<List<Book>> getBooksByCategory(String category);
  Future<void> addBook(Book book);
  Future<void> updateBook(Book book);
  Future<void> deleteBook(String id);
}

// Order Service
class OrderService {
  Future<Order> placeOrder(Order order);
  Future<List<Order>> getUserOrders(String userId);
  Future<List<Order>> getAllOrders(); // Admin only
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> cancelOrder(String orderId);
}
```

### Providers
```dart
// Main App Provider
class AppProvider extends ChangeNotifier {
  // Cart management
  List<CartItem> _cartItems = [];
  double get totalAmount => _calculateTotal();
  
  // User preferences
  bool _isDarkMode = false;
  String _selectedLanguage = 'en';
  String _selectedCurrency = 'USD';
  
  // Methods
  void addToCart(Book book, int quantity);
  void removeFromCart(String bookId);
  void updateCartItemQuantity(String bookId, int quantity);
  void clearCart();
}
```

## State Management

### Provider Pattern
The app uses Provider for state management. Key providers include:

```dart
// Auth Provider
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  
  Future<void> signIn(String email, String password);
  Future<void> signOut();
}

// Cart Provider
class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  
  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  double get total => _calculateTotal();
  
  void addItem(Book book, int quantity);
  void removeItem(String bookId);
  void clear();
}
```

### State Updates
```dart
// Example of state update
void addToCart(Book book, int quantity) {
  final existingIndex = _cartItems.indexWhere((item) => item.book.id == book.id);
  
  if (existingIndex >= 0) {
    _cartItems[existingIndex].quantity += quantity;
  } else {
    _cartItems.add(CartItem(book: book, quantity: quantity));
  }
  
  notifyListeners();
}
```

## Firebase Integration

### Authentication
```dart
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<User?> signIn(String email, String password) async {
  try {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
    return result.user;
  } catch (e) {
    throw AuthException(e.toString());
  }
}

Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    final result = await _auth.signInWithCredential(credential);
    return result.user;
  } catch (e) {
    throw AuthException(e.toString());
  }
}
```

### Firestore
```dart
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<List<Book>> getBooks() async {
  try {
    final snapshot = await _firestore.collection('books').get();
    return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
  } catch (e) {
    throw DatabaseException('Failed to fetch books: $e');
  }
}

Future<void> addBook(Book book) async {
  try {
    await _firestore.collection('books').add(book.toMap());
  } catch (e) {
    throw DatabaseException('Failed to add book: $e');
  }
}
```

### Storage
```dart
final FirebaseStorage _storage = FirebaseStorage.instance;

Future<String> uploadImage(File imageFile, String path) async {
  try {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    throw StorageException('Failed to upload image: $e');
  }
}
```

## Stripe Payment Integration

### Setup
```dart
// Initialize Stripe
await Stripe.instance.applySettings(
  StripeSettings(
    publishableKey: 'your_publishable_key',
    merchantIdentifier: 'your_merchant_identifier',
  ),
);
```

### Payment Processing
```dart
class PaymentService {
  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required String description,
  }) async {
    try {
      // Create payment intent
      final paymentIntent = await _createPaymentIntent(amount, currency);
      
      // Confirm payment
      await Stripe.instance.confirmPayment(
        paymentIntent['client_secret'],
        PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      
      return PaymentResult.success();
    } catch (e) {
      return PaymentResult.failure(e.toString());
    }
  }
}
```

### Payment Methods
```dart
// Save payment method
Future<void> savePaymentMethod(PaymentMethod paymentMethod) async {
  await _firestore
    .collection('users')
    .doc(_auth.currentUser!.uid)
    .collection('payment_methods')
    .add(paymentMethod.toMap());
}

// Get saved payment methods
Future<List<PaymentMethod>> getSavedPaymentMethods() async {
  final snapshot = await _firestore
    .collection('users')
    .doc(_auth.currentUser!.uid)
    .collection('payment_methods')
    .get();
    
  return snapshot.docs.map((doc) => PaymentMethod.fromMap(doc.data())).toList();
}
```

## Google Sign-In Integration

### Setup
```yaml
# pubspec.yaml
dependencies:
  google_sign_in: ^6.2.1
```

### Implementation
```dart
class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  Future<User?> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }
  
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
```

## Testing

### Unit Tests
```dart
void main() {
  group('BookService Tests', () {
    late BookService bookService;
    late MockFirebaseFirestore mockFirestore;
    
    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      bookService = BookService(firestore: mockFirestore);
    });
    
    test('should fetch books successfully', () async {
      // Arrange
      when(mockFirestore.collection('books').get())
        .thenAnswer((_) async => MockQuerySnapshot());
      
      // Act
      final books = await bookService.getBooks();
      
      // Assert
      expect(books, isNotEmpty);
      verify(mockFirestore.collection('books').get()).called(1);
    });
  });
}
```

### Widget Tests
```dart
void main() {
  testWidgets('BookList displays books correctly', (WidgetTester tester) async {
    // Arrange
    final mockBooks = [
      Book(id: '1', title: 'Test Book', author: 'Test Author', price: 9.99),
    ];
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: BookList(books: mockBooks),
      ),
    );
    
    // Assert
    expect(find.text('Test Book'), findsOneWidget);
    expect(find.text('Test Author'), findsOneWidget);
  });
}
```

### Integration Tests
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete purchase flow', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    
    // Login
    await tester.tap(find.text('Login'));
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    
    // Add to cart
    await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
    await tester.pumpAndSettle();
    
    // Verify cart
    expect(find.text('1'), findsOneWidget);
  });
}
```

## Deployment

### Android
1. **Update version** in `pubspec.yaml`:
   ```yaml
   version: 1.0.0+1
   ```

2. **Generate release build**:
   ```bash
   flutter build appbundle --release
   ```

3. **Upload to Google Play Console**:
   - Create new release
   - Upload AAB file
   - Add release notes
   - Submit for review

### iOS
1. **Update version** in Xcode project settings

2. **Generate release build**:
   ```bash
   flutter build ios --release
   ```

3. **Upload to App Store Connect**:
   - Archive in Xcode
   - Upload to App Store Connect
   - Submit for review

### Web
1. **Build for web**:
   ```bash
   flutter build web --release
   ```

2. **Deploy to hosting service**:
   - Firebase Hosting
   - Netlify
   - Vercel

## Best Practices

### Code Style
- Follow Flutter style guide
- Use meaningful variable and function names
- Add comprehensive comments for complex logic
- Keep methods small and focused (max 20 lines)
- Use const constructors where possible

### Performance
```dart
// Use const constructors
const BookCard({required this.book});

// Implement lazy loading
ListView.builder(
  itemCount: books.length,
  itemBuilder: (context, index) => BookCard(book: books[index]),
)

// Cache images
CachedNetworkImage(
  imageUrl: book.imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### Security
```dart
// Validate user input
String validateEmail(String email) {
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
    throw ValidationException('Invalid email format');
  }
  return email;
}

// Secure API keys
class ApiKeys {
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );
}

// Implement proper error handling
try {
  await performOperation();
} catch (e) {
  if (e is NetworkException) {
    showNetworkError();
  } else if (e is AuthException) {
    showAuthError();
  } else {
    showGenericError();
  }
}
```

### Error Handling
```dart
class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, [this.code]);
  
  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, 'NETWORK_ERROR');
}

class AuthException extends AppException {
  AuthException(String message) : super(message, 'AUTH_ERROR');
}
```

## Contributing

### Git Workflow
1. **Create feature branch**:
   ```bash
   git checkout -b feature/new-feature
   ```

2. **Make changes** and commit:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

3. **Write tests** for new functionality

4. **Submit pull request** with description

### Code Review Checklist
- [ ] Follows Flutter style guide
- [ ] Includes tests for new functionality
- [ ] Updates documentation
- [ ] No performance regressions
- [ ] Proper error handling
- [ ] Security considerations

## Troubleshooting

### Common Issues

#### Firebase Configuration
```bash
# Check Firebase setup
flutterfire configure

# Verify google-services.json
# Ensure it's in android/app/google-services.json
```

#### Build Errors
```bash
# Clean project
flutter clean
flutter pub get

# Check Flutter version
flutter --version

# Update dependencies
flutter pub upgrade
```

#### Runtime Errors
```bash
# Check logs
flutter logs

# Verify Firebase rules
# Test network connectivity
# Check API keys configuration
```

#### Payment Issues
- Verify Stripe keys are correct
- Check payment method configuration
- Ensure proper error handling
- Test with Stripe test cards

### Debug Tools
```dart
// Enable debug logging
Logger.level = Level.debug;

// Use device preview for testing
void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => MyApp(),
    ),
  );
}
```

## Support

For developer support:
- **GitHub Issues**: Report bugs and feature requests
- **Documentation**: Check this guide and inline code comments
- **Team Communication**: Use designated channels for questions

---

**Last Updated**: June 18, 2025