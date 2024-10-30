import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  EditProductScreen({required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController categoryController;
  List<WeightPrice> weightPrices = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    categoryController = TextEditingController(text: widget.product.category);
    weightPrices = widget.product.weightPrices;
  }

  void addWeightPriceField() {
    setState(() {
      weightPrices.add(WeightPrice(weight: 0, price: 0));
    });
  }

  void updateWeightPrice(int index, double weight, double price) {
    setState(() {
      weightPrices[index] = WeightPrice(weight: weight, price: price);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product')),
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
            SizedBox(height: 16),
            Text("Weight and Price Details"),
            ...weightPrices.asMap().entries.map((entry) {
              int index = entry.key;
              WeightPrice weightPrice = entry.value;
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Weight (g)'),
                      onChanged: (value) {
                        updateWeightPrice(
                            index, double.parse(value), weightPrice.price);
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Price (\$)'),
                      onChanged: (value) {
                        updateWeightPrice(
                            index, weightPrice.weight, double.parse(value));
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
            TextButton(
              onPressed: addWeightPriceField,
              child: Text("Add Weight and Price"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final updatedProduct = Product(
                  id: widget.product.id,
                  name: nameController.text,
                  category: categoryController.text,
                  weightPrices: weightPrices,
                );

                Provider.of<ProductProvider>(context, listen: false)
                    .updateProduct(updatedProduct);

                Navigator.pop(context); // Return to the previous screen
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
