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
      version: 3,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, category TEXT, type INTEGER)',
        );
        await db.execute(
          'CREATE TABLE weight_prices(id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER, weight REAL, price REAL, FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS weight_prices(id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER, weight REAL, price REAL, FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE)',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE products ADD COLUMN type INTEGER',
          );
        }
      },
    );
  }

  Future<void> insertProduct(Product product) async {
    final db = await database;
    int productId = await db.insert(
      'products',
      {
        'name': product.name,
        'category': product.category,
        'type': product.type.index, // Store type as an integer
      },
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

  Future<void> updateProduct(Product product) async {
    final db = await database;

    await db.update(
      'products',
      {
        'name': product.name,
        'category': product.category,
        'type': product.type.index, // Update type as an integer
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );

    // Delete old weight and price entries for the product
    await db.delete(
      'weight_prices',
      where: 'product_id = ?',
      whereArgs: [product.id],
    );

    // Insert updated weight and price entries
    for (var wp in product.weightPrices) {
      await db.insert(
        'weight_prices',
        {'product_id': product.id, 'weight': wp.weight, 'price': wp.price},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;

    // First, delete the weight_prices associated with the product
    await db.delete(
      'weight_prices',
      where: 'product_id = ?',
      whereArgs: [id],
    );

    // Then, delete the product itself
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
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
        type: ProductType.values[map['type']], // Retrieve type as enum
        weightPrices: weightPrices,
      ));
    }
    return products;
  }
}
