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
      version: 2, // Update version to force onUpgrade
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, category TEXT)',
        );
        await db.execute(
          'CREATE TABLE weight_prices(id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER, weight REAL, price REAL, FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Add missing table in case it was not created before
        if (oldVersion < 2) {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS weight_prices(id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER, weight REAL, price REAL, FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE)',
          );
        }
      },
    );
  }

  Future<void> insertProduct(Product product) async {
    final db = await database;
    int productId = await db.insert(
      'products',
      {'name': product.name, 'category': product.category},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (var wp in product.weightPrices) {
      await db.insert(
        'weight_prices',
        {'product_id': productId, 'weight': wp.weight, 'price': wp.price},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> productMaps = await db.query('products');

    List<Product> products = [];

    for (var map in productMaps) {
      int productId = map['id'];
      List<Map<String, dynamic>> weightPriceMaps = await db.query(
        'weight_prices',
        where: 'product_id = ?',
        whereArgs: [productId],
      );

      List<WeightPrice> weightPrices = weightPriceMaps.map((wpMap) {
        return WeightPrice(
          weight: wpMap['weight'],
          price: wpMap['price'],
        );
      }).toList();

      products.add(Product(
        id: productId,
        name: map['name'],
        category: map['category'],
        weightPrices: weightPrices,
      ));
    }
    return products;
  }
}
