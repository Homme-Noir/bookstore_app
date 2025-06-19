import 'package:bookstore_app/models/book.dart';
import 'package:bookstore_app/models/user_data.dart';
import 'package:bookstore_app/models/order.dart';
import 'package:bookstore_app/models/address.dart';
import 'package:bookstore_app/models/cart_item.dart';
import 'package:bookstore_app/models/review.dart';

/// Comprehensive test data for the Bookstore App
/// This file contains all the necessary test data for testing various features
/// of the bookstore application including books, users, orders, cart items, etc.

class TestData {
  // Sample Books
  static final List<Map<String, dynamic>> books = [
    {
      'id': 'book_001',
      'title': 'The Great Gatsby',
      'author': 'F. Scott Fitzgerald',
      'description': 'A story of the fabulously wealthy Jay Gatsby.',
      'coverImage': 'https://example.com/gatsby.jpg',
      'price': 12.99,
      'genres': ['Fiction', 'Classic'],
      'stock': 25,
      'rating': 4.5,
      'reviewCount': 128,
      'releaseDate': DateTime(1925, 4, 10),
      'isBestseller': true,
      'isNewArrival': false,
      'isbn': '978-0743273565',
      'pageCount': 180,
    },
    {
      'id': 'book_002',
      'title': 'To Kill a Mockingbird',
      'author': 'Harper Lee',
      'description': 'The story of young Scout Finch.',
      'coverImage': 'https://example.com/mockingbird.jpg',
      'price': 14.99,
      'genres': ['Fiction', 'Classic'],
      'stock': 30,
      'rating': 4.8,
      'reviewCount': 256,
      'releaseDate': DateTime(1960, 7, 11),
      'isBestseller': true,
      'isNewArrival': false,
      'isbn': '978-0446310789',
      'pageCount': 281,
    },
    {
      'id': 'book_003',
      'title': '1984',
      'author': 'George Orwell',
      'description':
          'A dystopian novel about totalitarianism and surveillance society.',
      'coverImage': 'https://example.com/1984.jpg',
      'price': 11.99,
      'genres': ['Fiction', 'Dystopian', 'Political'],
      'stock': 20,
      'rating': 4.6,
      'reviewCount': 189,
      'releaseDate': DateTime(1949, 6, 8),
      'isBestseller': true,
      'isNewArrival': false,
      'isbn': '978-0451524935',
      'pageCount': 328,
      'status': 'available',
      'authors': ['George Orwell'],
      'categories': ['Literature', 'Political Fiction'],
    },
    {
      'id': 'book_004',
      'title': 'The Hobbit',
      'author': 'J.R.R. Tolkien',
      'description':
          'A fantasy novel about Bilbo Baggins, a hobbit who embarks on an adventure.',
      'coverImage': 'https://example.com/hobbit.jpg',
      'price': 16.99,
      'genres': ['Fantasy', 'Adventure', 'Fiction'],
      'stock': 35,
      'rating': 4.7,
      'reviewCount': 312,
      'releaseDate': DateTime(1937, 9, 21),
      'isBestseller': true,
      'isNewArrival': false,
      'isbn': '978-0547928241',
      'pageCount': 366,
      'status': 'available',
      'authors': ['J.R.R. Tolkien'],
      'categories': ['Fantasy', 'Adventure'],
    },
    {
      'id': 'book_005',
      'title': 'Pride and Prejudice',
      'author': 'Jane Austen',
      'description':
          'A romantic novel of manners that follows the emotional development of Elizabeth Bennet.',
      'coverImage': 'https://example.com/pride.jpg',
      'price': 13.99,
      'genres': ['Romance', 'Classic', 'Fiction'],
      'stock': 28,
      'rating': 4.4,
      'reviewCount': 167,
      'releaseDate': DateTime(1813, 1, 28),
      'isBestseller': false,
      'isNewArrival': false,
      'isbn': '978-0141439518',
      'pageCount': 432,
      'status': 'available',
      'authors': ['Jane Austen'],
      'categories': ['Literature', 'Romance'],
    },
    {
      'id': 'book_006',
      'title': 'The Catcher in the Rye',
      'author': 'J.D. Salinger',
      'description':
          'A novel about teenage alienation and loss of innocence in post-World War II America.',
      'coverImage': 'https://example.com/catcher.jpg',
      'price': 10.99,
      'genres': ['Fiction', 'Coming-of-age', 'Classic'],
      'stock': 15,
      'rating': 4.2,
      'reviewCount': 98,
      'releaseDate': DateTime(1951, 7, 16),
      'isBestseller': false,
      'isNewArrival': false,
      'isbn': '978-0316769488',
      'pageCount': 277,
      'status': 'available',
      'authors': ['J.D. Salinger'],
      'categories': ['Literature', 'American Literature'],
    },
    {
      'id': 'book_007',
      'title': 'The Lord of the Rings',
      'author': 'J.R.R. Tolkien',
      'description':
          'An epic high-fantasy novel about the quest to destroy a powerful ring.',
      'coverImage': 'https://example.com/lotr.jpg',
      'price': 24.99,
      'genres': ['Fantasy', 'Adventure', 'Epic'],
      'stock': 40,
      'rating': 4.9,
      'reviewCount': 445,
      'releaseDate': DateTime(1954, 7, 29),
      'isBestseller': true,
      'isNewArrival': false,
      'isbn': '978-0547928210',
      'pageCount': 1216,
      'status': 'available',
      'authors': ['J.R.R. Tolkien'],
      'categories': ['Fantasy', 'Epic Fantasy'],
    },
    {
      'id': 'book_008',
      'title': 'Animal Farm',
      'author': 'George Orwell',
      'description':
          'An allegorical novella about a group of farm animals who rebel against their human farmer.',
      'coverImage': 'https://example.com/animal-farm.jpg',
      'price': 9.99,
      'genres': ['Fiction', 'Allegory', 'Political'],
      'stock': 22,
      'rating': 4.3,
      'reviewCount': 134,
      'releaseDate': DateTime(1945, 8, 17),
      'isBestseller': false,
      'isNewArrival': false,
      'isbn': '978-0451526342',
      'pageCount': 112,
      'status': 'available',
      'authors': ['George Orwell'],
      'categories': ['Literature', 'Political Fiction'],
    },
  ];

  // Sample Users
  static final List<Map<String, dynamic>> users = [
    {
      'id': 'user_001',
      'email': 'john.doe@example.com',
      'name': 'John Doe',
      'photoUrl': 'https://example.com/john.jpg',
      'addresses': ['address_001'],
      'paymentMethods': ['pm_001'],
      'isAdmin': false,
    },
    {
      'id': 'user_002',
      'email': 'admin@bookstore.com',
      'name': 'Admin User',
      'photoUrl': 'https://example.com/admin.jpg',
      'addresses': ['address_002'],
      'paymentMethods': ['pm_002'],
      'isAdmin': true,
    },
    {
      'id': 'user_003',
      'email': 'jane.smith@example.com',
      'name': 'Jane Smith',
      'photoUrl': 'https://example.com/jane.jpg',
      'addresses': ['address_003'],
      'paymentMethods': ['pm_003'],
      'isAdmin': false,
    },
    {
      'id': 'user_004',
      'email': 'bob.wilson@example.com',
      'name': 'Bob Wilson',
      'photoUrl': null,
      'addresses': ['address_005'],
      'paymentMethods': [],
      'isAdmin': false,
    },
  ];

  // Sample Addresses
  static final List<Map<String, dynamic>> addresses = [
    {
      'name': 'John Doe',
      'phoneNumber': '+1-555-0123',
      'flatNumber': 'Apt 101',
      'area': 'Downtown',
      'landmark': 'Near Central Park',
      'city': 'New York',
      'state': 'NY',
      'pincode': '10001',
    },
    {
      'name': 'Admin User',
      'phoneNumber': '+1-555-0789',
      'flatNumber': 'Office 500',
      'area': 'Financial District',
      'landmark': 'Near Wall Street',
      'city': 'New York',
      'state': 'NY',
      'pincode': '10005',
    },
    {
      'name': 'Jane Smith',
      'phoneNumber': '+1-555-0456',
      'flatNumber': 'Unit 15',
      'area': 'West Village',
      'landmark': 'Near Washington Square',
      'city': 'New York',
      'state': 'NY',
      'pincode': '10011',
    },
    {
      'name': 'Bob Wilson',
      'phoneNumber': '+1-555-0321',
      'flatNumber': 'Apt 303',
      'area': 'Brooklyn Heights',
      'landmark': 'Near Brooklyn Bridge',
      'city': 'Brooklyn',
      'state': 'NY',
      'pincode': '11201',
    },
  ];

  // Sample Cart Items
  static final List<Map<String, dynamic>> cartItems = [
    {
      'bookId': 'book_001',
      'title': 'The Great Gatsby',
      'coverImage': 'https://example.com/gatsby.jpg',
      'price': 12.99,
      'quantity': 2,
    },
    {
      'bookId': 'book_002',
      'title': 'To Kill a Mockingbird',
      'coverImage': 'https://example.com/mockingbird.jpg',
      'price': 14.99,
      'quantity': 1,
    },
    {
      'bookId': 'book_003',
      'title': '1984',
      'coverImage': 'https://example.com/1984.jpg',
      'price': 11.99,
      'quantity': 1,
    },
    {
      'bookId': 'book_004',
      'title': 'The Hobbit',
      'coverImage': 'https://example.com/hobbit.jpg',
      'price': 16.99,
      'quantity': 3,
    },
  ];

  // Sample Orders
  static final List<Map<String, dynamic>> orders = [
    {
      'id': 'order_001',
      'userId': 'user_001',
      'items': [
        {
          'bookId': 'book_001',
          'title': 'The Great Gatsby',
          'price': 12.99,
          'quantity': 1,
          'coverImage': 'https://example.com/gatsby.jpg',
        },
      ],
      'totalAmount': 18.98,
      'shippingAddress': addresses[0],
      'status': 'delivered',
      'createdAt': DateTime.now().subtract(Duration(days: 30)),
      'updatedAt': DateTime.now().subtract(Duration(days: 25)),
      'paymentId': 'pi_001',
      'trackingNumber': 'TRK123456789',
      'paymentMethod': 'credit_card',
      'shippingCost': 5.99,
      'tax': 0.00,
    },
    {
      'id': 'order_002',
      'userId': 'user_002',
      'items': [
        {
          'bookId': 'book_003',
          'title': '1984',
          'price': 11.99,
          'quantity': 1,
          'coverImage': 'https://example.com/1984.jpg',
        },
      ],
      'totalAmount': 17.98,
      'shippingAddress': addresses[2],
      'status': 'shipped',
      'createdAt': DateTime.now().subtract(Duration(days: 7)),
      'updatedAt': DateTime.now().subtract(Duration(days: 5)),
      'paymentId': 'pi_002',
      'trackingNumber': 'TRK987654321',
      'paymentMethod': 'paypal',
      'shippingCost': 5.99,
      'tax': 0.00,
    },
    {
      'id': 'order_003',
      'userId': 'user_001',
      'items': [
        {
          'bookId': 'book_004',
          'title': 'The Hobbit',
          'price': 16.99,
          'quantity': 1,
          'coverImage': 'https://example.com/hobbit.jpg',
        },
        {
          'bookId': 'book_007',
          'title': 'The Lord of the Rings',
          'price': 24.99,
          'quantity': 1,
          'coverImage': 'https://example.com/lotr.jpg',
        },
      ],
      'totalAmount': 47.97,
      'shippingAddress': addresses[1],
      'status': 'processing',
      'createdAt': DateTime.now().subtract(Duration(days: 2)),
      'updatedAt': DateTime.now().subtract(Duration(days: 1)),
      'paymentId': 'pi_003',
      'trackingNumber': null,
      'paymentMethod': 'credit_card',
      'shippingCost': 5.99,
      'tax': 0.00,
    },
  ];

  // Sample Reviews
  static final List<Map<String, dynamic>> reviews = [
    {
      'id': 'review_001',
      'bookId': 'book_001',
      'userId': 'user_001',
      'userName': 'John Doe',
      'userImage': 'https://example.com/john.jpg',
      'comment': 'A timeless classic!',
      'rating': 5.0,
      'createdAt': DateTime.now().subtract(Duration(days: 15)),
      'likes': 12,
      'likedBy': ['user_002'],
    },
    {
      'id': 'review_002',
      'bookId': 'book_001',
      'userId': 'user_004',
      'userName': 'Bob Wilson',
      'userImage': null,
      'comment':
          'Good book but a bit slow in the beginning. The ending makes up for it though.',
      'rating': 4.0,
      'createdAt': DateTime.now().subtract(Duration(days: 10)),
      'likes': 5,
      'likedBy': ['user_002'],
    },
    {
      'id': 'review_003',
      'bookId': 'book_002',
      'userId': 'user_001',
      'userName': 'John Doe',
      'userImage': 'https://example.com/john.jpg',
      'comment':
          'Powerful story about justice and racism. A must-read for everyone.',
      'rating': 5.0,
      'createdAt': DateTime.now().subtract(Duration(days: 20)),
      'likes': 25,
      'likedBy': ['user_002', 'user_004'],
    },
    {
      'id': 'review_004',
      'bookId': 'book_003',
      'userId': 'user_002',
      'userName': 'Jane Smith',
      'userImage': 'https://example.com/jane.jpg',
      'comment':
          'Disturbing but important. Orwell\'s vision of totalitarianism is still relevant today.',
      'rating': 4.5,
      'createdAt': DateTime.now().subtract(Duration(days: 8)),
      'likes': 18,
      'likedBy': ['user_001', 'user_004'],
    },
    {
      'id': 'review_005',
      'bookId': 'book_004',
      'userId': 'user_001',
      'userName': 'John Doe',
      'userImage': 'https://example.com/john.jpg',
      'comment':
          'A wonderful adventure story. Perfect for both children and adults.',
      'rating': 4.8,
      'createdAt': DateTime.now().subtract(Duration(days: 12)),
      'likes': 22,
      'likedBy': ['user_002', 'user_004'],
    },
  ];

  // Helper methods that create model instances directly
  static Book createBook(Map<String, dynamic> data) {
    return Book(
      id: data['id'] as String,
      title: data['title'] as String,
      author: data['author'] as String,
      description: data['description'] as String,
      coverImage: data['coverImage'] as String,
      price: (data['price'] as num).toDouble(),
      genres: List<String>.from(data['genres'] as List),
      stock: data['stock'] as int,
      rating: (data['rating'] as num).toDouble(),
      reviewCount: data['reviewCount'] as int,
      releaseDate: data['releaseDate'] as DateTime,
      isBestseller: data['isBestseller'] as bool? ?? false,
      isNewArrival: data['isNewArrival'] as bool? ?? false,
      isbn: data['isbn'] as String? ?? '',
      pageCount: data['pageCount'] as int? ?? 0,
    );
  }

  static UserData createUser(Map<String, dynamic> data) {
    return UserData.fromMap(data);
  }

  static ShippingAddress createAddress(Map<String, dynamic> data) {
    return ShippingAddress.fromJson(data);
  }

  static CartItem createCartItem(Map<String, dynamic> data) {
    return CartItem.fromMap(data);
  }

  static Order createOrder(Map<String, dynamic> data) {
    return Order(
      id: data['id'] as String,
      userId: data['userId'] as String,
      items: (data['items'] as List)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      shippingAddress: ShippingAddress.fromJson(
        data['shippingAddress'] as Map<String, dynamic>,
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: data['createdAt'] as DateTime,
      updatedAt:
          data['updatedAt'] != null ? data['updatedAt'] as DateTime : null,
      paymentId: data['paymentId'] as String?,
      trackingNumber: data['trackingNumber'] as String?,
      paymentMethod: data['paymentMethod'] as String?,
      shippingCost: (data['shippingCost'] as num?)?.toDouble(),
      tax: (data['tax'] as num?)?.toDouble(),
    );
  }

  static Review createReview(Map<String, dynamic> data) {
    return Review(
      id: data['id'] as String,
      bookId: data['bookId'] as String,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      userImage: data['userImage'] as String,
      comment: data['comment'] as String,
      rating: (data['rating'] as num).toDouble(),
      createdAt: data['createdAt'] as DateTime,
      likes: data['likes'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
    );
  }

  // Sample categories for filtering
  static final List<String> sampleCategories = [
    'Fiction',
    'Non-Fiction',
    'Classic',
    'Romance',
    'Fantasy',
    'Adventure',
    'Drama',
    'Political',
    'Dystopian',
    'Coming-of-age',
    'Epic',
    'Allegory',
    'Literature',
    'American Literature',
    'Epic Fantasy',
    'Political Fiction',
  ];

  // Sample genres for filtering
  static final List<String> sampleGenres = [
    'Fiction',
    'Classic',
    'Romance',
    'Drama',
    'Fantasy',
    'Adventure',
    'Political',
    'Dystopian',
    'Coming-of-age',
    'Epic',
    'Allegory',
  ];

  // Sample payment methods
  static final List<Map<String, dynamic>> samplePaymentMethods = [
    {
      'id': 'pm_001',
      'type': 'credit_card',
      'last4': '4242',
      'brand': 'visa',
      'expMonth': 12,
      'expYear': 2025,
    },
    {
      'id': 'pm_002',
      'type': 'credit_card',
      'last4': '5555',
      'brand': 'mastercard',
      'expMonth': 8,
      'expYear': 2026,
    },
    {
      'id': 'pm_003',
      'type': 'paypal',
      'email': 'jane.smith@example.com',
    },
    {
      'id': 'pm_004',
      'type': 'credit_card',
      'last4': '1234',
      'brand': 'amex',
      'expMonth': 3,
      'expYear': 2027,
    },
  ];
}
