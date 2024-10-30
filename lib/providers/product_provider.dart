import 'package:flutter/material.dart';
import '../models/product.dart';
import '../database/database_helper.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

   List<Product> get products => _filteredProducts.isNotEmpty ? _filteredProducts : _products;

  Future<void> loadProducts() async {
    _products = await _dbHelper.getProducts();
    _filteredProducts = _products; // Initially show all products
    notifyListeners();
  }

  void filterByCategory(String category) {
    if (category.isEmpty) {
      _filteredProducts = _products;
    } else {
      _filteredProducts = _products.where((product) => product.category == category).toList();
    }
    notifyListeners();
  }

  void searchByName(String query) {
    if (query.isEmpty) {
      _filteredProducts = _products; // Show all if query is empty
    } else {
      _filteredProducts = _products.where((product) => product.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
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
