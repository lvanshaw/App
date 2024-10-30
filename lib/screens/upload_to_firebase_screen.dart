import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/database/database_helper.dart';
import 'package:myapp/models/product.dart';
import 'package:intl/intl.dart';

class UploadToFirebaseScreen extends StatefulWidget {
  const UploadToFirebaseScreen({super.key});

  @override
  _UploadToFirebaseScreenState createState() => _UploadToFirebaseScreenState();
}

class _UploadToFirebaseScreenState extends State<UploadToFirebaseScreen> {
  bool _isFirebaseInitialized = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Product> _products = [];

  Future<void> uploadProductsToFirebase() async {
    // Initialize Firebase if not initialized
    if (!_isFirebaseInitialized) {
      try {
        await Firebase.initializeApp();
        _isFirebaseInitialized = true;
      } catch (e) {
        print("Error initializing Firebase: $e");
        return;
      }
    }

    // Fetch products from local database
    _products = await _dbHelper.getProducts();

    // Get Firebase Database reference
    final databaseRef = FirebaseDatabase.instance.ref();

    // Generate a unique timestamp for the node
    final String dateTimeNode =
        DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final productsRef =
        databaseRef.child('product').child('product_$dateTimeNode');

    // Initialize a counter for successful uploads
    int successCount = 0;

    // Upload each product to Firebase
    for (var product in _products) {
      final productData = {
        'name': product.name,
        'category': product.category,
        'type':
            product.type.toString().split('.').last, // Include type as a string
        'weightPrices': product.weightPrices
            .map((wp) => {
                  'weight': wp.weight,
                  'price': wp.price,
                })
            .toList(),
      };

      try {
        await productsRef.push().set(productData);
        print("Product ${product.name} uploaded successfully!");
        successCount++; // Increment successful upload counter
      } catch (e) {
        print("Error uploading product ${product.name}: $e");
      }
    }

    // Show success or failure message in SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successCount > 0
            ? "$successCount products uploaded successfully!"
            : "No products uploaded."),
        duration: Duration(seconds: 3),
      ),
    );

    print("All products uploaded successfully!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Products')),
      body: Center(
        child: ElevatedButton(
          onPressed: uploadProductsToFirebase,
          child: Text('Upload Products'),
        ),
      ),
    );
  }
}
