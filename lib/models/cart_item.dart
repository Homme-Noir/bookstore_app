class CartItem {
  final String bookId;
  final String title;
  final String coverImage;
  final double price;
  final int quantity;

  const CartItem({
    required this.bookId,
    required this.title,
    required this.coverImage,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'coverImage': coverImage,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      bookId: map['bookId'] as String,
      title: map['title'] as String,
      coverImage: map['coverImage'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }

  CartItem copyWith({
    String? bookId,
    String? title,
    String? coverImage,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
} 