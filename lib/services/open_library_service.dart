import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class OpenLibraryService {
  static const String _baseUrl = 'https://openlibrary.org';

  /// Gets a default list of popular books from Open Library API.
  Future<List<Book>> getDefaultBooks() async {
    final raw = await defaultOpenLibraryRaw();
    return raw.map(convertToBook).toList();
  }

  /// Raw Open Library search hits (includes Internet Archive ids when present).
  Future<List<OpenLibraryBook>> defaultOpenLibraryRaw() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search.json?q=fiction&limit=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final docs = data['docs'] as List;

        return docs
            .map((doc) => OpenLibraryBook.fromSearchResult(doc))
            .cast<OpenLibraryBook>()
            .toList();
      } else {
        throw Exception('Failed to get default books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting default books: $e');
    }
  }

  /// Gets books by category/genre from Open Library API.
  Future<List<Book>> getBooksByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/search.json?subject=${Uri.encodeComponent(category)}&limit=15'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final docs = data['docs'] as List;

        return docs
            .map((doc) => OpenLibraryBook.fromSearchResult(doc))
            .map((olBook) => convertToBook(olBook))
            .toList();
      } else {
        throw Exception(
            'Failed to get books by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting books by category: $e');
    }
  }

  /// Gets books for specific categories with different queries
  Future<List<Book>> getBooksForCategory(String category) async {
    try {
      String query;
      String? fallbackQuery;
      switch (category.toLowerCase()) {
        case 'action':
          query = 'action adventure thriller';
          fallbackQuery = 'action';
          break;
        case 'romance':
          query = 'romance love story';
          fallbackQuery = 'romance';
          break;
        case 'mystery':
          query = 'mystery detective crime';
          fallbackQuery = 'mystery';
          break;
        case 'science fiction':
          query = 'science fiction sci-fi';
          fallbackQuery = 'science fiction';
          break;
        case 'fantasy':
          query = 'fantasy magic adventure';
          fallbackQuery = 'fantasy';
          break;
        case 'biography':
          query = 'biography memoir autobiography';
          fallbackQuery = 'biography';
          break;
        case 'history':
          query = 'history historical';
          fallbackQuery = 'history';
          break;
        case 'self-help':
          query = 'self-help personal development';
          fallbackQuery = 'self-help';
          break;
        case 'business':
          query = 'business economics management';
          fallbackQuery = 'business';
          break;
        case 'cooking':
          query = 'cooking food recipes';
          fallbackQuery = 'cooking';
          break;
        case 'horror':
          query = 'horror scary thriller';
          fallbackQuery = 'horror';
          break;
        case 'children':
          query = 'children kids juvenile';
          fallbackQuery = 'children';
          break;
        case 'comics':
          query = 'comics graphic novels manga';
          fallbackQuery = 'comics';
          break;
        case 'poetry':
          query = 'poetry poems verse';
          fallbackQuery = 'poetry';
          break;
        case 'classics':
          query = 'classics literature';
          fallbackQuery = 'classics';
          break;
        case 'health':
          query = 'health wellness fitness';
          fallbackQuery = 'health';
          break;
        case 'travel':
          query = 'travel adventure';
          fallbackQuery = 'travel';
          break;
        case 'religion':
          query = 'religion spirituality faith';
          fallbackQuery = 'religion';
          break;
        case 'art':
          query = 'art design painting';
          fallbackQuery = 'art';
          break;
        case 'science':
          query = 'science nature';
          fallbackQuery = 'science';
          break;
        case 'technology':
          query = 'technology computers';
          fallbackQuery = 'technology';
          break;
        case 'sports':
          query = 'sports games athletics';
          fallbackQuery = 'sports';
          break;
        case 'technology':
          query = 'technology computer science programming';
          break;
        case 'philosophy':
          query = 'philosophy ethics metaphysics';
          break;
        case 'psychology':
          query = 'psychology mental health behavior';
          break;
        case 'travel':
          query = 'travel guide tourism adventure';
          break;
        case 'art':
          query = 'art painting sculpture design';
          break;
        case 'music':
          query = 'music musicians composers';
          break;
        case 'poetry':
          query = 'poetry poems verse';
          break;
        case 'children':
          query = 'children kids picture books';
          break;
        case 'young adult':
          query = 'young adult teen fiction';
          break;
        case 'thriller':
          query = 'thriller suspense tension';
          break;
        case 'horror':
          query = 'horror scary supernatural';
          break;
        case 'comedy':
          query = 'comedy humor funny';
          break;
        case 'drama':
          query = 'drama theatrical plays';
          break;
        case 'adventure':
          query = 'adventure exploration journey';
          break;
        case 'classic literature':
          query = 'classic literature classics';
          break;
        default:
          query = category;
      }

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/search.json?q=${Uri.encodeComponent(query)}&limit=15'),
      );

      List<Book> books = [];
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final docs = data['docs'] as List;
        books = docs
            .map((doc) => OpenLibraryBook.fromSearchResult(doc))
            .map((olBook) => convertToBook(olBook))
            .toList();
      }

      // If no books found and fallbackQuery is set, try fallback
      if (books.isEmpty && fallbackQuery != null) {
        final fallbackResponse = await http.get(
          Uri.parse(
              '$_baseUrl/search.json?q=${Uri.encodeComponent(fallbackQuery)}&limit=15'),
        );
        if (fallbackResponse.statusCode == 200) {
          final data = json.decode(fallbackResponse.body);
          final docs = data['docs'] as List;
          books = docs
              .map((doc) => OpenLibraryBook.fromSearchResult(doc))
              .map((olBook) => convertToBook(olBook))
              .toList();
        }
      }

      return books;
    } catch (e) {
      throw Exception('Error getting books for category: $e');
    }
  }

  /// Searches for books by title, author, or general query using Open Library API.
  Future<List<Book>> searchBooks(String query) async {
    final raw = await searchOpenLibraryRaw(query);
    return raw.map(convertToBook).toList();
  }

  /// Raw Open Library search hits (includes Internet Archive ids when present).
  Future<List<OpenLibraryBook>> searchOpenLibraryRaw(String query) async {
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
            .cast<OpenLibraryBook>()
            .toList();
      } else {
        throw Exception('Failed to search books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching books: $e');
    }
  }

  /// Gets book details by ISBN from Open Library API.
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

  /// Gets book details by Open Library ID from Open Library API.
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

  /// Converts an OpenLibraryBook to the app's Book model.
  Book convertToBook(OpenLibraryBook olBook) {
    return Book(
      id: olBook.openLibraryId ??
          'book_${DateTime.now().millisecondsSinceEpoch}',
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
      isbn: olBook.isbn ?? '',
      pageCount: olBook.pageCount ?? 0,
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
  /// Internet Archive item ids (when Open Library links a scan / OA file).
  final List<String> internetArchiveIds;

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
    this.internetArchiveIds = const [],
  });

  factory OpenLibraryBook.fromSearchResult(Map<String, dynamic> data) {
    return OpenLibraryBook(
      title: data['title'] ?? '',
      authors: OpenLibraryBook.extractAuthors(data['author_name']),
      description: data['first_sentence']?.first ?? '',
      coverImage: _getCoverImage(data['cover_i']),
      publishDate: _parseDate(data['first_publish_year']),
      isbn: _extractIsbn(data['isbn']),
      pageCount: data['number_of_pages_median'],
      subjects: OpenLibraryBook.extractSubjects(data['subject']),
      publisher: data['publisher']?.first,
      openLibraryId: data['key'],
      internetArchiveIds: _extractInternetArchiveIds(data['ia']),
    );
  }

  factory OpenLibraryBook.fromIsbnResult(
      Map<String, dynamic> data, String isbn) {
    return OpenLibraryBook(
      title: data['title'] ?? '',
      authors: OpenLibraryBook.extractAuthorsFromIsbn(data['authors']),
      description: data['excerpts']?.first?['text'] ?? '',
      coverImage: _getCoverImageFromIsbn(data['cover']),
      publishDate: _parseDateFromIsbn(data['publish_date']),
      isbn: isbn,
      pageCount: data['number_of_pages'],
      subjects: _extractSubjectsFromIsbn(data['subjects']),
      publisher: data['publishers']?.first?['name'],
      openLibraryId: data['key'],
      internetArchiveIds: const [],
    );
  }

  factory OpenLibraryBook.fromWorkResult(Map<String, dynamic> data) {
    return OpenLibraryBook(
      title: data['title'] ?? '',
      authors: OpenLibraryBook.extractAuthors(data['authors']),
      description: data['description']?['value'] ?? '',
      coverImage: _getCoverImageFromWork(data['covers']),
      publishDate: _parseDateFromWork(data['first_publish_date']),
      isbn: null, // Not available in work data
      pageCount: null,
      subjects: OpenLibraryBook.extractSubjects(data['subjects']),
      publisher: null,
      openLibraryId: data['key'],
      internetArchiveIds: const [],
    );
  }

  static List<String> _extractInternetArchiveIds(dynamic ia) {
    if (ia is! List) return const [];
    return ia
        .map((e) => e.toString())
        .where((s) => s.trim().isNotEmpty)
        .take(8)
        .toList();
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

  static List<String> _extractSubjectsFromIsbn(dynamic subjectsData) {
    if (subjectsData is List) {
      return subjectsData.map((subject) => subject['name'] as String).toList();
    }
    return [];
  }

  static List<String> extractAuthors(dynamic authorData) {
    if (authorData is List) {
      return authorData.cast<String>();
    }
    return [];
  }

  static List<String> extractSubjects(dynamic subjectsData) {
    if (subjectsData is List) {
      return subjectsData.cast<String>();
    }
    return [];
  }

  static List<String> extractAuthorsFromIsbn(dynamic authorsData) {
    if (authorsData is List) {
      return authorsData.map((author) => author['name'] as String).toList();
    }
    return [];
  }
}
