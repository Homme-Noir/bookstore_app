import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String? isbn;
  final int? pageCount;
  final String? status;
  final List<String>? authors;
  final List<String>? categories;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImage,
    required this.price,
    required this.genres,
    required this.stock,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.releaseDate,
    this.isBestseller = false,
    this.isNewArrival = false,
    this.isbn,
    this.pageCount,
    this.status,
    this.authors,
    this.categories,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      description: data['description'] ?? '',
      coverImage: data['coverImage'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      genres: List<String>.from(data['genres'] ?? []),
      stock: data['stock'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      releaseDate: (data['releaseDate'] as Timestamp).toDate(),
      isBestseller: data['isBestseller'] ?? false,
      isNewArrival: data['isNewArrival'] ?? false,
      isbn: data['isbn'] as String?,
      pageCount: data['pageCount'] as int?,
      status: data['status'] as String?,
      authors: data['authors'] != null ? List<String>.from(data['authors']) : null,
      categories: data['categories'] != null ? List<String>.from(data['categories']) : null,
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String? ?? '',
      title: json['title'] as String,
      author: json['author'] as String? ?? '',
      description: json['description'] as String? ?? '',
      coverImage: json['coverImage'] as String? ?? json['thumbnailUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
      stock: json['stock'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      releaseDate: json['releaseDate'] != null
          ? (json['releaseDate'] as Timestamp).toDate()
          : DateTime.now(),
      isBestseller: json['isBestseller'] as bool? ?? false,
      isNewArrival: json['isNewArrival'] as bool? ?? false,
      isbn: json['isbn'] as String?,
      pageCount: json['pageCount'] as int?,
      status: json['status'] as String?,
      authors: json['authors'] != null ? List<String>.from(json['authors']) : null,
      categories: json['categories'] != null ? List<String>.from(json['categories']) : null,
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
      'releaseDate': Timestamp.fromDate(releaseDate),
      'isBestseller': isBestseller,
      'isNewArrival': isNewArrival,
      if (isbn != null) 'isbn': isbn,
      if (pageCount != null) 'pageCount': pageCount,
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
      publishedDate: PublishedDate.fromJson(json['publishedDate'] as Map<String, dynamic>),
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
