import 'models/book.dart';
import 'models/user_data.dart';

class MockData {
  static final List<Book> books = [
    Book(
      id: 'book_001',
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      description: 'A story of the fabulously wealthy Jay Gatsby.',
      coverImage: 'https://covers.openlibrary.org/b/id/7222246-L.jpg',
      price: 12.99,
      genres: ['Fiction', 'Classic'],
      stock: 25,
      rating: 4.5,
      reviewCount: 128,
      releaseDate: DateTime(1925, 4, 10),
      isBestseller: true,
      isNewArrival: false,
      isbn: '978-0743273565',
      pageCount: 180,
    ),
    Book(
      id: 'book_002',
      title: 'To Kill a Mockingbird',
      author: 'Harper Lee',
      description: 'The story of young Scout Finch.',
      coverImage: 'https://covers.openlibrary.org/b/id/8228691-L.jpg',
      price: 14.99,
      genres: ['Fiction', 'Classic'],
      stock: 30,
      rating: 4.8,
      reviewCount: 256,
      releaseDate: DateTime(1960, 7, 11),
      isBestseller: true,
      isNewArrival: false,
      isbn: '978-0446310789',
      pageCount: 281,
    ),
    // ... add more books as needed ...
  ];

  static final List<UserData> users = [
    UserData(
      id: 'user_001',
      email: 'john.doe@example.com',
      name: 'John Doe',
      photoUrl: 'https://example.com/john.jpg',
      addresses: [], // Fill with mock addresses if needed
      paymentMethods: [],
      isAdmin: false,
    ),
    UserData(
      id: 'user_002',
      email: 'admin@bookstore.com',
      name: 'Admin User',
      photoUrl: 'https://example.com/admin.jpg',
      addresses: [],
      paymentMethods: [],
      isAdmin: true,
    ),
    // ... add more users as needed ...
  ];

  // Add similar mock lists for orders, addresses, cart items, reviews, etc.
}
