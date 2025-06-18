import 'package:flutter_test/flutter_test.dart';
import 'test_data.dart';

void main() {
  group('TestData', () {
    test('should create book from test data', () {
      final bookData = TestData.books[0];
      final book = TestData.createBook(bookData);

      expect(book.title, 'The Great Gatsby');
      expect(book.author, 'F. Scott Fitzgerald');
      expect(book.price, 12.99);
    });

    test('should create user from test data', () {
      final userData = TestData.users[0];
      final user = TestData.createUser(userData);

      expect(user.name, 'John Doe');
      expect(user.email, 'john.doe@example.com');
      expect(user.isAdmin, false);
    });
  });
}
