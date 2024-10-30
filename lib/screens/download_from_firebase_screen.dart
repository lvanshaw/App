import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/database/database_helper.dart';
import 'package:myapp/models/product.dart';

class DownloadFromFirebaseScreen extends StatefulWidget {
  const DownloadFromFirebaseScreen({super.key});

  @override
  _DownloadFromFirebaseScreenState createState() =>
      _DownloadFromFirebaseScreenState();
}

class _DownloadFromFirebaseScreenState
    extends State<DownloadFromFirebaseScreen> {
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> downloadLatestProductFromFirebase() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Reference to the 'products' node in Firebase
      final databaseRef = FirebaseDatabase.instance.ref().child('product');

      // Get the latest product
      final snapshot = await databaseRef.orderByKey().limitToLast(1).once();
      final latestProductData =
          snapshot.snapshot.value as Map<dynamic, dynamic>?;
      if (latestProductData != null && latestProductData.isNotEmpty) {
        final latestEntry = latestProductData.entries.first.value;
        //print(latestEntry);
        // Check for null values and assign defaults or throw errors as needed
        final productName = latestEntry['name'] ?? 'Unknown'; // Default if null
        final productCategory =
            latestEntry['category'] ?? 'Uncategorized'; // Default if null
        final productTypeString = latestEntry['type'];
        final productType = productTypeString != null
            ? ProductType.values.firstWhere(
                (type) => type.toString().split('.').last == productTypeString,
                orElse: () => ProductType.weight) // Default type
            : ProductType.weight; // Default if null

        // Create the product object
        final product = Product(
          id: null, // Auto-increment ID will be assigned in Sqflite
          name: productName,
          category: productCategory,
          weightPrices: (latestEntry['weightPrices'] as List<dynamic>?)
                  ?.map((wp) => WeightPrice(
                        weight: wp['weight'],
                        price: wp['price'],
                      ))
                  .toList() ??
              [],
          type: productType,
        );

        await _dbHelper.insertProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Latest product downloaded successfully!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No products found in Firebase.")));
      }
    } catch (e) {
      print("Error downloading products: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error downloading products.")));
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
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
