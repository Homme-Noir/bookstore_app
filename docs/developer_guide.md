# Book Store App - Developer Guide

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Setup and Installation](#setup-and-installation)
4. [Project Structure](#project-structure)
5. [Key Components](#key-components)
6. [State Management](#state-management)
7. [Firebase Integration](#firebase-integration)
8. [Testing](#testing)
9. [Deployment](#deployment)
10. [Best Practices](#best-practices)

## Project Overview

The Book Store app is a Flutter-based e-commerce application that allows users to browse, purchase, and manage books. The app uses Firebase for backend services and follows a clean architecture pattern.

### Tech Stack
- Flutter (Dart)
- Firebase (Authentication, Firestore, Storage)
- Provider (State Management)
- GetIt (Dependency Injection)

## Architecture

### Clean Architecture
The app follows clean architecture principles with the following layers:
- Presentation Layer (UI)
- Domain Layer (Business Logic)
- Data Layer (Repository Implementation)

### Directory Structure
```
lib/
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
├── services/       # Business logic
├── utils/          # Utilities
└── widgets/        # Reusable widgets
```

## Setup and Installation

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Firebase account
- Git

### Environment Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/Homme-Noir/bookstore_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps
   - Download and add configuration files
   - Enable required Firebase services

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

### Models
- `Book`: Represents a book with properties like title, author, price
- `User`: User profile and authentication data
- `Order`: Order details and status
- `CartItem`: Shopping cart item representation

### Services
- `AuthService`: Handles user authentication
- `BookService`: Manages book-related operations
- `OrderService`: Handles order processing
- `StorageService`: Manages file storage

### Providers
- `AppProvider`: Main state management provider
- `AuthProvider`: Authentication state
- `CartProvider`: Shopping cart state
- `ThemeProvider`: App theme management

## Key Components

### Authentication
```dart
class AuthService {
  Future<User?> signIn(String email, String password);
  Future<User?> register(String email, String password);
  Future<void> signOut();
}
```

### Book Management
```dart
class BookService {
  Future<List<Book>> getBooks();
  Future<Book> getBookById(String id);
  Future<void> addBook(Book book);
  Future<void> updateBook(Book book);
}
```

### Order Processing
```dart
class OrderService {
  Future<Order> placeOrder(Order order);
  Future<List<Order>> getUserOrders(String userId);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
}
```

## State Management

### Provider Pattern
The app uses Provider for state management. Key providers include:

```dart
class AppProvider extends ChangeNotifier {
  // Cart management
  List<CartItem> _cartItems = [];
  double get totalAmount => _calculateTotal();
  
  // User preferences
  bool _isDarkMode = false;
  String _selectedLanguage = 'en';
}
```

### State Updates
```dart
// Example of state update
void addToCart(Book book) {
  _cartItems.add(CartItem(book: book, quantity: 1));
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
```

### Firestore
```dart
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<List<Book>> getBooks() async {
  final snapshot = await _firestore.collection('books').get();
  return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
}
```

## Testing

### Unit Tests
```dart
void main() {
  group('BookService Tests', () {
    test('should fetch books successfully', () async {
      final service = BookService();
      final books = await service.getBooks();
      expect(books, isNotEmpty);
    });
  });
}
```

### Widget Tests
```dart
void main() {
  testWidgets('BookList displays books correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.byType(BookCard), findsWidgets);
  });
}
```

## Deployment

### Android
1. Update version in `pubspec.yaml`
2. Generate release build:
   ```bash
   flutter build appbundle
   ```
3. Upload to Google Play Console

### iOS
1. Update version in Xcode
2. Generate release build:
   ```bash
   flutter build ios
   ```
3. Upload to App Store Connect

## Best Practices

### Code Style
- Follow Flutter style guide
- Use meaningful variable names
- Add comments for complex logic
- Keep methods small and focused

### Performance
- Use const constructors
- Implement lazy loading
- Cache images and data
- Minimize rebuilds

### Security
- Validate user input
- Secure API keys
- Implement proper error handling
- Use secure storage for sensitive data

### Error Handling
```dart
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

## Contributing

### Git Workflow
1. Create feature branch
2. Make changes
3. Write tests
4. Submit pull request

### Code Review
- Follow style guide
- Add tests
- Update documentation
- Check performance impact

## Troubleshooting

### Common Issues
1. Firebase configuration
   - Check google-services.json
   - Verify Firebase initialization

2. Build errors
   - Clean project
   - Update dependencies
   - Check Flutter version

3. Runtime errors
   - Check logs
   - Verify Firebase rules
   - Test network connectivity

## Support

For developer support:
- GitHub Issues
- Developer Documentation
- Team Communication Channel

---

_Last updated: June 17, 2025_