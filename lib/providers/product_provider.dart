  import 'package:flutter/material.dart';
  import '../models/product.dart';
  import '../database/database_helper.dart';

  class ProductProvider with ChangeNotifier {
    List<Product> _products = [];
    List<Product> _filteredProducts = [];
    final DatabaseHelper _dbHelper = DatabaseHelper();

    List<Product> get products =>
        _filteredProducts.isNotEmpty ? _filteredProducts : _products;

    Future<void> loadProducts() async {
      try {
        _products = await _dbHelper.getProducts();
        _filteredProducts = _products; // Initially show all products
        notifyListeners();
      } catch (error) {
        print("Error loading products: $error"); // For debugging
      }
    }

    void filterByCategory(String category) {
      if (category.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts =
            _products.where((product) => product.category == category).toList();
      }
      notifyListeners();
    }

    void filterByType(ProductType type) {
      _filteredProducts =
          _products.where((product) => product.type == type).toList();
      notifyListeners();
    }

    void searchByName(String query) {
      if (query.isEmpty) {
        _filteredProducts = List.from(_products); // Reset to all products
      } else {
        _filteredProducts = _products.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      notifyListeners();
    }

    void resetProducts() {
      _filteredProducts = List.from(_products); // Reset to all products
      notifyListeners();
    }

    Future<void> deleteProduct(int id) async {
      // Call the database helper to delete the product
      await _dbHelper.deleteProduct(id);

      // Remove the product from the in-memory list
      _products.removeWhere((product) => product.id == id);
      _filteredProducts.removeWhere((product) => product.id == id);

      // Notify listeners about the changes
      notifyListeners();
    }

    Future<void> deleteAllProducts() async {
      try {
        await _dbHelper.deleteAllProducts();
        _products.clear(); // Clear the in-memory list
        _filteredProducts.clear(); // Clear the filtered list
        notifyListeners(); // Notify listeners about the changes
      } catch (error) {
        print("Error deleting all products: $error");
      }
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
