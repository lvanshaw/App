import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/database/database_helper.dart';
import 'package:myapp/models/product.dart';
import 'package:firebase_core/firebase_core.dart';

class DownloadFromFirebaseScreen extends StatefulWidget {
  const DownloadFromFirebaseScreen({super.key});

  @override
  _DownloadFromFirebaseScreenState createState() =>
      _DownloadFromFirebaseScreenState();
}

class _DownloadFromFirebaseScreenState
    extends State<DownloadFromFirebaseScreen> {
  bool _isLoading = false;
  bool _isFirebaseInitialized = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> downloadLatestProductFromFirebase() async {
    setState(() {
      _isLoading = true;
    });

    if (!_isFirebaseInitialized) {
      try {
        await Firebase.initializeApp();
        _isFirebaseInitialized = true;
      } catch (e) {
        print("Error initializing Firebase: $e");
        _showMessage("Error initializing Firebase.");
        setState(() => _isLoading = false);
        return;
      }
    }

    try {
      final databaseRef = FirebaseDatabase.instance.ref().child('product');
      final snapshot = await databaseRef.orderByKey().limitToLast(1).once();
      final productsData = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (productsData != null && productsData.isNotEmpty) {
        for (var entry in productsData.entries) {
          final productKey = entry.key;
          final productMap = entry.value as Map<dynamic, dynamic>;

          // Print the product key
          //print("Product Key: $productKey");

          // Extract and print each product's details
          productMap.forEach((key, value) async {
            // Extracting individual product details
            final productData = value as Map<dynamic, dynamic>;
            final productName = productData['name'] ?? 'Unknown';
            final productCategory = productData['category'] ?? 'Uncategorized';
            final productTypeString = productData['type'];

            // Print product details
            //print("Product Name: $productName");
            //print("Product Category: $productCategory");
            //print("Product Type: $productTypeString");

            // Parse weight and price list
            final weightPrices =
                (productData['weightPrices'] as List<dynamic>?)?.map((wp) {
                      final price = wp['price']?.toDouble() ?? 0.0;
                      final weight = wp['weight']?.toDouble() ?? 0.0;
                      print("Weight: $weight, Price: $price");
                      return WeightPrice(weight: weight, price: price);
                    }).toList() ??
                    [];

            // Create Product instance
            final product = Product(
              id: null, // ID auto-generated in database
              name: productName,
              category: productCategory,
              weightPrices: weightPrices,
              type: ProductType.values.firstWhere(
                (type) => type.toString().split('.').last == productTypeString,
                orElse: () => ProductType.weight,
              ),
            );

            // Insert product into local database
            await _dbHelper.deleteAllProducts();
            await _dbHelper.insertProduct(product);
            print("Inserted product: ${product.name}");
          });
        }

        _showMessage("Products downloaded and saved successfully!");
      } else {
        _showMessage("No products found in Firebase.");
      }
    } catch (e) {
      print("Error downloading products: $e");
      _showMessage("Error downloading products.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Download Latest Product')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: downloadLatestProductFromFirebase,
                child: Text('Download Latest Product from Firebase'),
              ),
      ),
    );
  }
}
