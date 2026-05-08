import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/body_measurement.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bodyfit.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL,
        trial_ends_at TEXT NOT NULL,
        is_subscribed INTEGER DEFAULT 0,
        subscription_type TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE body_measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        height REAL NOT NULL,
        weight REAL NOT NULL,
        chest REAL NOT NULL,
        waist REAL NOT NULL,
        hips REAL NOT NULL,
        shoulder REAL NOT NULL,
        arm_length REAL NOT NULL,
        leg_length REAL NOT NULL,
        neck REAL NOT NULL,
        foot_length REAL NOT NULL,
        body_type TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        product_url TEXT NOT NULL,
        marketplace TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        query TEXT NOT NULL,
        category TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // User operations
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Body measurement operations
  Future<int> insertMeasurement(BodyMeasurement measurement) async {
    final db = await database;
    return await db.insert('body_measurements', measurement.toMap());
  }

  Future<List<BodyMeasurement>> getMeasurements(int userId) async {
    final db = await database;
    final maps = await db.query(
      'body_measurements',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => BodyMeasurement.fromMap(m)).toList();
  }

  Future<BodyMeasurement?> getLatestMeasurement(int userId) async {
    final db = await database;
    final maps = await db.query(
      'body_measurements',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return BodyMeasurement.fromMap(maps.first);
  }

  // Favorites operations
  Future<void> addFavorite(int userId, String productId, String name,
      String url, String marketplace) async {
    final db = await database;
    await db.insert('favorites', {
      'user_id': userId,
      'product_id': productId,
      'product_name': name,
      'product_url': url,
      'marketplace': marketplace,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFavorite(int userId, String productId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites(int userId) async {
    final db = await database;
    return await db.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  // Search history
  Future<void> addSearchHistory(
      int userId, String query, String? category) async {
    final db = await database;
    await db.insert('search_history', {
      'user_id': userId,
      'query': query,
      'category': category,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getSearchHistory(int userId) async {
    final db = await database;
    return await db.query(
      'search_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: 20,
    );
  }
}
