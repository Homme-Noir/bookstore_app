# Test Data for Bookstore App

This directory contains test data and utilities for testing the bookstore application.

## Files

- `widget_test.dart` - Basic widget tests for the app
- `test_data.dart` - Comprehensive test data for all app models
- `README.md` - This file

## Test Data Usage

The `test_data.dart` file contains sample data for all the main entities in the bookstore app:

### Available Test Data

1. **Books** (`TestData.books`)
   - Sample books with titles, authors, prices, ratings, etc.
   - Includes classics like "The Great Gatsby" and "To Kill a Mockingbird"
   - Each book has complete metadata (ISBN, page count, genres, etc.)

2. **Users** (`TestData.users`)
   - Regular users and admin users
   - Includes email, name, photo URL, addresses, and payment methods
   - Different user types for testing various scenarios

3. **Addresses** (`TestData.addresses`)
   - Shipping addresses with complete information
   - Different locations for testing address validation

4. **Cart Items** (`TestData.cartItems`)
   - Sample shopping cart items
   - Different quantities and books for testing cart functionality

5. **Orders** (`TestData.orders`)
   - Sample orders with different statuses
   - Includes order items, shipping addresses, and payment information

6. **Reviews** (`TestData.reviews`)
   - Sample book reviews with ratings and comments
   - Different users and ratings for testing review functionality

### Helper Methods

The `TestData` class provides helper methods to create model instances:

```dart
// Create a Book instance from test data
Book book = TestData.createBook(TestData.books[0]);

// Create a User instance from test data
UserData user = TestData.createUser(TestData.users[0]);

// Create an Address instance from test data
ShippingAddress address = TestData.createAddress(TestData.addresses[0]);

// Create a Cart Item instance from test data
CartItem cartItem = TestData.createCartItem(TestData.cartItems[0]);

// Create an Order instance from test data
Order order = TestData.createOrder(TestData.orders[0]);

// Create a Review instance from test data
Review review = TestData.createReview(TestData.reviews[0]);
```

### Example Usage in Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bookstore_app/test/test_data.dart';

void main() {
  group('Book Tests', () {
    test('should create book from test data', () {
      final bookData = TestData.books[0];
      final book = TestData.createBook(bookData);
      
      expect(book.title, 'The Great Gatsby');
      expect(book.author, 'F. Scott Fitzgerald');
      expect(book.price, 12.99);
    });
  });

  group('User Tests', () {
    test('should create user from test data', () {
      final userData = TestData.users[0];
      final user = TestData.createUser(userData);
      
      expect(user.name, 'John Doe');
      expect(user.email, 'john.doe@example.com');
      expect(user.isAdmin, false);
    });
  });
}
```

### Testing Scenarios

The test data supports various testing scenarios:

1. **Authentication Testing**
   - Regular user login/logout
   - Admin user functionality
   - User profile management

2. **Book Management Testing**
   - Book listing and filtering
   - Book search functionality
   - Book details and reviews

3. **Shopping Cart Testing**
   - Adding/removing items
   - Quantity updates
   - Price calculations

4. **Order Management Testing**
   - Order creation and processing
   - Different order statuses
   - Order history and tracking

5. **Address Management Testing**
   - Address validation
   - Multiple addresses per user
   - Shipping address selection

6. **Review System Testing**
   - Adding reviews
   - Rating calculations
   - Review moderation

### Mock DocumentSnapshot

The file includes a `MockDocumentSnapshot` class for testing Firestore operations without requiring a real Firebase connection.

### Notes

- All image URLs are placeholder URLs (`https://example.com/...`)
- Phone numbers are fake test numbers
- Email addresses are test emails
- Prices and ratings are realistic but fictional
- Dates are set relative to the current date for realistic testing

### Adding More Test Data

To add more test data, simply extend the existing arrays in `TestData` class:

```dart
static final List<Map<String, dynamic>> books = [
  // ... existing books
  {
    'id': 'book_009',
    'title': 'New Test Book',
    // ... other book properties
  },
];
```

This test data file provides a solid foundation for comprehensive testing of your bookstore application. 