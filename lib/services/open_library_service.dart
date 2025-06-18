import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class OpenLibraryService {
  static const String _baseUrl = 'https://openlibrary.org';

  /// Search for books by title, author, or general query
  Future<List<OpenLibraryBook>> searchBooks(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/search.json?q=${Uri.encodeComponent(query)}&limit=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final docs = data['docs'] as List;

        return docs
            .map((doc) => OpenLibraryBook.fromSearchResult(doc))
            .toList();
      } else {
        throw Exception('Failed to search books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching books: $e');
    }
  }

  /// Get book details by ISBN
  Future<OpenLibraryBook?> getBookByIsbn(String isbn) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/books?bibkeys=ISBN:$isbn&format=json&jscmd=data'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bookKey = 'ISBN:$isbn';

        if (data.containsKey(bookKey)) {
          return OpenLibraryBook.fromIsbnResult(data[bookKey], isbn);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error getting book by ISBN: $e');
    }
  }

  /// Get book details by Open Library ID
  Future<OpenLibraryBook?> getBookById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/works/$id.json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OpenLibraryBook.fromWorkResult(data);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting book by ID: $e');
    }
  }

  /// Convert OpenLibraryBook to your app's Book model
  Book convertToBook(OpenLibraryBook olBook) {
    return Book(
      id: '', // Will be set when saving to Firestore
      title: olBook.title,
      author: olBook.authors.isNotEmpty ? olBook.authors.first : '',
      authors: olBook.authors.isNotEmpty ? olBook.authors : null,
      description: olBook.description ?? '',
      coverImage: olBook.coverImage ?? '',
      price: 0.0, // Default price, can be set manually
      genres:
          olBook.subjects.take(5).toList(), // Use first 5 subjects as genres
      stock: 0, // Default stock, can be set manually
      rating: 0.0,
      reviewCount: 0,
      releaseDate: olBook.publishDate ?? DateTime.now(),
      isBestseller: false,
      isNewArrival: false,
      isbn: olBook.isbn,
      pageCount: olBook.pageCount,
      status: 'available',
      categories: olBook.subjects.isNotEmpty ? olBook.subjects : null,
    );
  }
}

class OpenLibraryBook {
  final String title;
  final List<String> authors;
  final String? description;
  final String? coverImage;
  final DateTime? publishDate;
  final String? isbn;
  final int? pageCount;
  final List<String> subjects;
  final String? publisher;
  final String? openLibraryId;

  OpenLibraryBook({
    required this.title,
    required this.authors,
    this.description,
    this.coverImage,
    this.publishDate,
    this.isbn,
    this.pageCount,
    required this.subjects,
    this.publisher,
    this.openLibraryId,
  });

  factory OpenLibraryBook.fromSearchResult(Map<String, dynamic> data) {
    return OpenLibraryBook(
      title: data['title'] ?? '',
      authors: _extractAuthors(data['author_name']),
      description: data['first_sentence']?.first ?? '',
      coverImage: _getCoverImage(data['cover_i']),
      publishDate: _parseDate(data['first_publish_year']),
      isbn: _extractIsbn(data['isbn']),
      pageCount: data['number_of_pages_median'],
      subjects: _extractSubjects(data['subject']),
      publisher: data['publisher']?.first,
      openLibraryId: data['key'],
    );
  }

  factory OpenLibraryBook.fromIsbnResult(
      Map<String, dynamic> data, String isbn) {
    return OpenLibraryBook(
      title: data['title'] ?? '',
      authors: _extractAuthorsFromIsbn(data['authors']),
      description: data['excerpts']?.first?['text'] ?? '',
      coverImage: _getCoverImageFromIsbn(data['cover']),
      publishDate: _parseDateFromIsbn(data['publish_date']),
      isbn: isbn,
      pageCount: data['number_of_pages'],
      subjects: _extractSubjectsFromIsbn(data['subjects']),
      publisher: data['publishers']?.first?['name'],
      openLibraryId: data['key'],
    );
  }

  factory OpenLibraryBook.fromWorkResult(Map<String, dynamic> data) {
    return OpenLibraryBook(
      title: data['title'] ?? '',
      authors: _extractAuthorsFromWork(data['authors']),
      description: data['description']?['value'] ?? '',
      coverImage: _getCoverImageFromWork(data['covers']),
      publishDate: _parseDateFromWork(data['first_publish_date']),
      isbn: null, // Not available in work data
      pageCount: null,
      subjects: _extractSubjectsFromWork(data['subjects']),
      publisher: null,
      openLibraryId: data['key'],
    );
  }

  static List<String> _extractAuthors(dynamic authorData) {
    if (authorData is List) {
      return authorData.cast<String>();
    }
    return [];
  }

  static List<String> _extractAuthorsFromIsbn(dynamic authorsData) {
    if (authorsData is List) {
      return authorsData.map((author) => author['name'] as String).toList();
    }
    return [];
  }

  static List<String> _extractAuthorsFromWork(dynamic authorsData) {
    if (authorsData is List) {
      return authorsData
          .map((author) => author['author']['key'] as String)
          .toList();
    }
    return [];
  }

  static String? _getCoverImage(dynamic coverId) {
    if (coverId != null) {
      return 'https://covers.openlibrary.org/b/id/$coverId-L.jpg';
    }
    return null;
  }

  static String? _getCoverImageFromIsbn(dynamic coverData) {
    if (coverData != null && coverData['large'] != null) {
      return coverData['large'];
    }
    return null;
  }

  static String? _getCoverImageFromWork(dynamic coversData) {
    if (coversData is List && coversData.isNotEmpty) {
      return 'https://covers.openlibrary.org/b/id/${coversData.first}-L.jpg';
    }
    return null;
  }

  static DateTime? _parseDate(dynamic year) {
    if (year != null) {
      try {
        return DateTime(int.parse(year.toString()));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static DateTime? _parseDateFromIsbn(String? dateStr) {
    if (dateStr != null) {
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return _parseDate(dateStr);
      }
    }
    return null;
  }

  static DateTime? _parseDateFromWork(String? dateStr) {
    if (dateStr != null) {
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static String? _extractIsbn(dynamic isbnData) {
    if (isbnData is List && isbnData.isNotEmpty) {
      return isbnData.first;
    }
    return null;
  }

  static List<String> _extractSubjects(dynamic subjectsData) {
    if (subjectsData is List) {
      return subjectsData.cast<String>();
    }
    return [];
  }

  static List<String> _extractSubjectsFromIsbn(dynamic subjectsData) {
    if (subjectsData is List) {
      return subjectsData.map((subject) => subject['name'] as String).toList();
    }
    return [];
  }

  static List<String> _extractSubjectsFromWork(dynamic subjectsData) {
    if (subjectsData is List) {
      return subjectsData.map((subject) => subject['name'] as String).toList();
    }
    return [];
  }
}
