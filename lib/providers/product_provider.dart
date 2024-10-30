import 'package:flutter/material.dart';
import '../models/product.dart';
import '../database/database_helper.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Product> get products => _products;

  Future<void> fetchProducts() async {
    _products = await _dbHelper.getProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _dbHelper.insertProduct(product);
    await fetchProducts();
  }
}
