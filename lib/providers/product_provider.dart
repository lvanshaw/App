import 'package:flutter/material.dart';
import '../models/product.dart';
import '../database/database_helper.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Product> get products => _products;

  Future<void> loadProducts() async {
    _products = await _dbHelper.getProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _dbHelper.insertProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _dbHelper.updateProduct(product);
    await loadProducts(); // Refresh product list
  }
}
