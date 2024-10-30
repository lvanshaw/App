import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'grocery_store.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, category TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert(
      'products',
      {'name': product.name, 'category': product.category},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['id'],
        name: maps[i]['name'],
        category: maps[i]['category'],
        weightPrices: [], // Logic for weightPrices can be implemented as needed
      );
    });
  }
}
