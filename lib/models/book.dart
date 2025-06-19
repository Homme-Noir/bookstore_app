class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverImage;
  final double price;
  final List<String> genres;
  final int stock;
  final double rating;
  final int reviewCount;
  final DateTime releaseDate;
  final bool isBestseller;
  final bool isNewArrival;
  final String isbn;
  final int pageCount;
  final String? status;
  final List<String>? authors;
  final List<String>? categories;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImage,
    required this.price,
    required this.genres,
    required this.stock,
    required this.rating,
    required this.reviewCount,
    required this.releaseDate,
    required this.isBestseller,
    required this.isNewArrival,
    required this.isbn,
    required this.pageCount,
    this.status,
    this.authors,
    this.categories,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      description: json['description'] as String,
      coverImage: json['coverImage'] as String,
      price: (json['price'] ?? 0.0).toDouble(),
      genres: List<String>.from(json['genres'] ?? []),
      stock: json['stock'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      releaseDate: json['releaseDate'] is DateTime
          ? json['releaseDate'] as DateTime
          : DateTime.tryParse(json['releaseDate'].toString()) ?? DateTime.now(),
      isBestseller: json['isBestseller'] as bool? ?? false,
      isNewArrival: json['isNewArrival'] as bool? ?? false,
      isbn: json['isbn'] as String,
      pageCount: json['pageCount'] as int,
      status: json['status'] as String?,
      authors:
          json['authors'] != null ? List<String>.from(json['authors']) : null,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'coverImage': coverImage,
      'price': price,
      'genres': genres,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'releaseDate': releaseDate,
      'isBestseller': isBestseller,
      'isNewArrival': isNewArrival,
      'isbn': isbn,
      'pageCount': pageCount,
      if (status != null) 'status': status,
      if (authors != null) 'authors': authors,
      if (categories != null) 'categories': categories,
    };
  }
}

class BookModel {
  final String title;
  final String isbn;
  final int pageCount;
  final PublishedDate publishedDate;
  final String thumbnailUrl;
  final String longDescription;
  final String status;
  final int price;
  final List<String> authors;
  final List<String> categories;

  const BookModel({
    required this.title,
    required this.isbn,
    required this.pageCount,
    required this.publishedDate,
    required this.thumbnailUrl,
    required this.longDescription,
    required this.status,
    required this.price,
    required this.authors,
    required this.categories,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      title: json['title'] as String,
      isbn: json['isbn'] as String,
      pageCount: json['pageCount'] as int,
      publishedDate: PublishedDate.fromJson(
        json['publishedDate'] as Map<String, dynamic>,
      ),
      thumbnailUrl: json['thumbnailUrl'] as String,
      longDescription: json['longDescription'] as String,
      status: json['status'] as String,
      price: json['price'] as int,
      authors: List<String>.from(json['authors'] as List),
      categories: List<String>.from(json['categories'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isbn': isbn,
      'price': price,
      'pageCount': pageCount,
      'publishedDate': publishedDate.toJson(),
      'thumbnailUrl': thumbnailUrl,
      'longDescription': longDescription,
      'status': status,
      'authors': authors,
      'categories': categories,
    };
  }
}

class PublishedDate {
  final String date;

  const PublishedDate({required this.date});

  factory PublishedDate.fromJson(Map<String, dynamic> json) {
    return PublishedDate(date: json['date'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'date': date};
  }
}
