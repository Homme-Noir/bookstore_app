# Book Store App - API Documentation

## Table of Contents
1. [Overview](#overview)
2. [Firebase Firestore Collections](#firebase-firestore-collections)
3. [Data Models](#data-models)
4. [Authentication Endpoints](#authentication-endpoints)
5. [Book Management APIs](#book-management-apis)
6. [Order Management APIs](#order-management-apis)
7. [User Management APIs](#user-management-apis)
8. [Payment APIs](#payment-apis)
9. [Error Handling](#error-handling)
10. [Rate Limiting](#rate-limiting)

## Overview

The Book Store app uses Firebase Firestore as its primary database and Firebase Authentication for user management. All API interactions are handled through Firebase SDKs and custom service classes.

### Base Configuration
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage
- **Payment**: Stripe API

## Firebase Firestore Collections

### Users Collection
**Path**: `users/{userId}`

```json
{
  "uid": "string",
  "email": "string",
  "fullName": "string",
  "phoneNumber": "string?",
  "profileImageUrl": "string?",
  "isAdmin": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "addresses": "array",
  "preferences": {
    "theme": "string",
    "language": "string",
    "currency": "string",
    "notifications": "boolean"
  }
}
```

### Books Collection
**Path**: `books/{bookId}`

```json
{
  "id": "string",
  "title": "string",
  "author": "string",
  "description": "string",
  "isbn": "string",
  "price": "number",
  "originalPrice": "number?",
  "discountPercentage": "number?",
  "imageUrl": "string",
  "category": "string",
  "subcategory": "string?",
  "stockQuantity": "number",
  "rating": "number",
  "reviewCount": "number",
  "publishedDate": "timestamp",
  "publisher": "string",
  "language": "string",
  "pages": "number?",
  "format": "string",
  "isActive": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Orders Collection
**Path**: `orders/{orderId}`

```json
{
  "id": "string",
  "userId": "string",
  "items": [
    {
      "bookId": "string",
      "title": "string",
      "author": "string",
      "price": "number",
      "quantity": "number",
      "imageUrl": "string"
    }
  ],
  "totalAmount": "number",
  "subtotal": "number",
  "tax": "number",
  "shipping": "number",
  "discount": "number",
  "status": "string",
  "paymentStatus": "string",
  "paymentMethod": "string",
  "shippingAddress": "object",
  "billingAddress": "object",
  "trackingNumber": "string?",
  "estimatedDelivery": "timestamp?",
  "orderDate": "timestamp",
  "updatedAt": "timestamp"
}
```

### Reviews Collection
**Path**: `reviews/{reviewId}`

```json
{
  "id": "string",
  "bookId": "string",
  "userId": "string",
  "userName": "string",
  "rating": "number",
  "title": "string",
  "comment": "string",
  "isVerified": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Wishlists Collection
**Path**: `wishlists/{userId}`

```json
{
  "userId": "string",
  "items": [
    {
      "bookId": "string",
      "addedAt": "timestamp"
    }
  ],
  "updatedAt": "timestamp"
}
```

### Payment Methods Collection
**Path**: `users/{userId}/payment_methods/{paymentMethodId}`

```json
{
  "id": "string",
  "type": "string",
  "last4": "string",
  "brand": "string",
  "expMonth": "number",
  "expYear": "number",
  "isDefault": "boolean",
  "createdAt": "timestamp"
}
```

## Data Models

### Book Model
```dart
class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String isbn;
  final double price;
  final double? originalPrice;
  final double? discountPercentage;
  final String imageUrl;
  final String category;
  final String? subcategory;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
  final DateTime publishedDate;
  final String publisher;
  final String language;
  final int? pages;
  final String format;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Methods
  Map<String, dynamic> toMap();
  factory Book.fromMap(Map<String, dynamic> map);
  factory Book.fromFirestore(DocumentSnapshot doc);
}
```

### Order Model
```dart
class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final double subtotal;
  final double tax;
  final double shipping;
  final double discount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String paymentMethod;
  final Address shippingAddress;
  final Address billingAddress;
  final String? trackingNumber;
  final DateTime? estimatedDelivery;
  final DateTime orderDate;
  final DateTime updatedAt;

  // Methods
  Map<String, dynamic> toMap();
  factory Order.fromMap(Map<String, dynamic> map);
  factory Order.fromFirestore(DocumentSnapshot doc);
}
```

### User Model
```dart
class UserData {
  final String uid;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Address> addresses;
  final UserPreferences preferences;

  // Methods
  Map<String, dynamic> toMap();
  factory UserData.fromMap(Map<String, dynamic> map);
  factory UserData.fromFirestore(DocumentSnapshot doc);
}
```

## Authentication Endpoints

### Sign Up
```dart
Future<User?> register(String email, String password, String fullName)
```

**Request**:
```json
{
  "email": "user@example.com",
  "password": "password123",
  "fullName": "John Doe"
}
```

**Response**: Firebase User object

**Error Codes**:
- `email-already-in-use`: Email already registered
- `invalid-email`: Invalid email format
- `weak-password`: Password too weak

### Sign In
```dart
Future<User?> signIn(String email, String password)
```

**Request**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response**: Firebase User object

**Error Codes**:
- `user-not-found`: User doesn't exist
- `wrong-password`: Incorrect password
- `user-disabled`: Account disabled

### Google Sign In
```dart
Future<User?> signInWithGoogle()
```

**Response**: Firebase User object

**Error Codes**:
- `popup-closed-by-user`: User closed popup
- `network-request-failed`: Network error

### Sign Out
```dart
Future<void> signOut()
```

### Password Reset
```dart
Future<void> resetPassword(String email)
```

**Request**:
```json
{
  "email": "user@example.com"
}
```

## Book Management APIs

### Get All Books
```dart
Future<List<Book>> getBooks({
  String? category,
  String? searchQuery,
  String? sortBy,
  int? limit,
  DocumentSnapshot? lastDocument
})
```

**Query Parameters**:
- `category`: Filter by category
- `searchQuery`: Search in title/author
- `sortBy`: `price_asc`, `price_desc`, `rating`, `newest`
- `limit`: Number of results (default: 20)
- `lastDocument`: For pagination

**Response**:
```json
{
  "books": [
    {
      "id": "book1",
      "title": "Sample Book",
      "author": "John Author",
      "price": 19.99,
      "rating": 4.5,
      "imageUrl": "https://example.com/image.jpg"
    }
  ],
  "hasMore": true,
  "lastDocument": "document_reference"
}
```

### Get Book by ID
```dart
Future<Book> getBookById(String bookId)
```

**Response**: Book object with full details

### Search Books
```dart
Future<List<Book>> searchBooks(String query, {
  String? category,
  double? minPrice,
  double? maxPrice,
  double? minRating
})
```

**Request**:
```json
{
  "query": "flutter development",
  "category": "technology",
  "minPrice": 10.0,
  "maxPrice": 50.0,
  "minRating": 4.0
}
```

### Add Book (Admin Only)
```dart
Future<void> addBook(Book book)
```

**Request**: Book object with all required fields

### Update Book (Admin Only)
```dart
Future<void> updateBook(String bookId, Map<String, dynamic> updates)
```

### Delete Book (Admin Only)
```dart
Future<void> deleteBook(String bookId)
```

## Order Management APIs

### Place Order
```dart
Future<Order> placeOrder(Order order)
```

**Request**:
```json
{
  "items": [
    {
      "bookId": "book1",
      "quantity": 2
    }
  ],
  "shippingAddress": {
    "street": "123 Main St",
    "city": "New York",
    "state": "NY",
    "zipCode": "10001",
    "country": "USA"
  },
  "paymentMethod": "card_1234567890"
}
```

**Response**: Created Order object

### Get User Orders
```dart
Future<List<Order>> getUserOrders(String userId, {
  OrderStatus? status,
  int? limit,
  DocumentSnapshot? lastDocument
})
```

### Get All Orders (Admin Only)
```dart
Future<List<Order>> getAllOrders({
  OrderStatus? status,
  DateTime? startDate,
  DateTime? endDate,
  int? limit
})
```

### Update Order Status (Admin Only)
```dart
Future<void> updateOrderStatus(String orderId, OrderStatus status)
```

### Cancel Order
```dart
Future<void> cancelOrder(String orderId)
```

## User Management APIs

### Get User Profile
```dart
Future<UserData> getUserProfile(String userId)
```

### Update User Profile
```dart
Future<void> updateUserProfile(String userId, Map<String, dynamic> updates)
```

**Request**:
```json
{
  "fullName": "John Doe",
  "phoneNumber": "+1234567890",
  "profileImageUrl": "https://example.com/avatar.jpg"
}
```

### Add Address
```dart
Future<void> addAddress(String userId, Address address)
```

### Update Address
```dart
Future<void> updateAddress(String userId, String addressId, Address address)
```

### Delete Address
```dart
Future<void> deleteAddress(String userId, String addressId)
```

### Get User Preferences
```dart
Future<UserPreferences> getUserPreferences(String userId)
```

### Update User Preferences
```dart
Future<void> updateUserPreferences(String userId, UserPreferences preferences)
```

## Payment APIs

### Create Payment Intent
```dart
Future<Map<String, dynamic>> createPaymentIntent({
  required double amount,
  required String currency,
  required String description
})
```

**Request**:
```json
{
  "amount": 2999,
  "currency": "usd",
  "description": "Book purchase"
}
```

**Response**:
```json
{
  "client_secret": "pi_1234567890_secret_abcdef",
  "id": "pi_1234567890"
}
```

### Confirm Payment
```dart
Future<PaymentResult> confirmPayment(String clientSecret, PaymentMethodParams params)
```

### Save Payment Method
```dart
Future<void> savePaymentMethod(String userId, PaymentMethod paymentMethod)
```

### Get Saved Payment Methods
```dart
Future<List<PaymentMethod>> getSavedPaymentMethods(String userId)
```

### Delete Payment Method
```dart
Future<void> deletePaymentMethod(String userId, String paymentMethodId)
```

## Error Handling

### Error Response Format
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": {
      "field": "additional_error_details"
    }
  }
}
```

### Common Error Codes

#### Authentication Errors
- `auth/user-not-found`: User doesn't exist
- `auth/wrong-password`: Incorrect password
- `auth/email-already-in-use`: Email already registered
- `auth/invalid-email`: Invalid email format
- `auth/weak-password`: Password too weak
- `auth/user-disabled`: Account disabled

#### Database Errors
- `permission-denied`: Insufficient permissions
- `not-found`: Document not found
- `already-exists`: Document already exists
- `invalid-argument`: Invalid data provided
- `unavailable`: Service temporarily unavailable

#### Payment Errors
- `payment_intent_invalid`: Invalid payment intent
- `card_declined`: Card declined by bank
- `insufficient_funds`: Insufficient funds
- `expired_card`: Card expired
- `invalid_cvc`: Invalid CVC

### Error Handling Example
```dart
try {
  final result = await authService.signIn(email, password);
  return result;
} catch (e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'user-not-found':
        throw AuthException('User not found');
      case 'wrong-password':
        throw AuthException('Incorrect password');
      default:
        throw AuthException('Authentication failed');
    }
  }
  throw AuthException('Unknown error occurred');
}
```

## Rate Limiting

### Firebase Firestore Limits
- **Read operations**: 1,000,000 per day (free tier)
- **Write operations**: 20,000 per day (free tier)
- **Delete operations**: 20,000 per day (free tier)

### Stripe API Limits
- **Requests per second**: 100 (live mode), 25 (test mode)
- **Daily requests**: No limit

### Best Practices
1. **Implement caching** for frequently accessed data
2. **Use pagination** for large datasets
3. **Batch operations** when possible
4. **Monitor usage** to stay within limits
5. **Implement retry logic** with exponential backoff

### Caching Strategy
```dart
class CacheService {
  static const Duration _cacheDuration = Duration(minutes: 15);
  final Map<String, CachedData> _cache = {};

  Future<T?> getCachedData<T>(String key) async {
    final cached = _cache[key];
    if (cached != null && !cached.isExpired) {
      return cached.data as T;
    }
    return null;
  }

  void setCachedData<T>(String key, T data) {
    _cache[key] = CachedData(
      data: data,
      timestamp: DateTime.now(),
    );
  }
}
```

---

**Last Updated**: June 18, 2025 