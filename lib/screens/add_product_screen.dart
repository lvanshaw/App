import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class AddProductScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            ElevatedButton(
              onPressed: () {
                final product = Product(
                  name: nameController.text,
                  category: categoryController.text,
                  weightPrices: [], // Implement weight and price handling
                );
                Provider.of<ProductProvider>(context, listen: false)
                    .addProduct(product);
                Navigator.pop(context); // Return to the previous screen
              },
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
