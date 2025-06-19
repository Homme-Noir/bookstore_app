import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bookstore.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        photoUrl TEXT,
        isAdmin INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE books (
        id TEXT PRIMARY KEY,
        title TEXT,
        author TEXT,
        description TEXT,
        coverImage TEXT,
        price REAL,
        genres TEXT,
        stock INTEGER,
        rating REAL,
        reviewCount INTEGER,
        releaseDate TEXT,
        isBestseller INTEGER,
        isNewArrival INTEGER,
        isbn TEXT,
        pageCount INTEGER,
        status TEXT,
        authors TEXT,
        categories TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE cart (
        userId TEXT,
        bookId TEXT,
        title TEXT,
        coverImage TEXT,
        price REAL,
        quantity INTEGER,
        PRIMARY KEY (userId, bookId)
      )
    ''');
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        userId TEXT,
        items TEXT,
        totalAmount REAL,
        shippingAddress TEXT,
        status TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        paymentId TEXT,
        trackingNumber TEXT,
        paymentMethod TEXT,
        shippingCost REAL,
        tax REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE wishlist (
        userId TEXT,
        bookId TEXT,
        PRIMARY KEY (userId, bookId)
      )
    ''');
    await db.execute('''
      CREATE TABLE reviews (
        id TEXT PRIMARY KEY,
        bookId TEXT,
        userId TEXT,
        userName TEXT,
        userImage TEXT,
        comment TEXT,
        rating REAL,
        createdAt TEXT,
        likes INTEGER,
        likedBy TEXT
      )
    ''');
  }

  // Add more helper methods as needed
}
