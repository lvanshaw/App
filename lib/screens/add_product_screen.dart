import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final List<WeightPrice> weightPrices = [];

  final TextEditingController weightController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void addWeightPrice() {
    if (weightController.text.isNotEmpty && priceController.text.isNotEmpty) {
      setState(() {
        weightPrices.add(
          WeightPrice(
            weight: double.parse(weightController.text),
            price: double.parse(priceController.text),
          ),
        );
        weightController.clear();
        priceController.clear();
      });
    }
  }

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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    decoration: InputDecoration(labelText: 'Weight (g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: addWeightPrice,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: weightPrices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                        'Weight: ${weightPrices[index].weight}g, Price: \$${weightPrices[index].price}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final product = Product(
                  name: nameController.text,
                  category: categoryController.text,
                  weightPrices: weightPrices,
                );
                Provider.of<ProductProvider>(context, listen: false)
                    .addProduct(product);
                Navigator.pop(context);
              },
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
