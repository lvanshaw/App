import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final List<WeightPrice> weightPrices = [];
  final TextEditingController weightController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String? selectedCategory;
  ProductType? selectedType;

  final List<String> categories = ['Fruits', 'Vegetables', 'Dairy', 'Grains'];

  void addWeightPrice() {
    if (priceController.text.isNotEmpty) {
      setState(() {
        weightPrices.add(
          WeightPrice(
            weight: selectedType == ProductType.single
                ? 1
                : double.parse(weightController.text),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(labelText: 'Category'),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            DropdownButtonFormField<ProductType>(
              value: selectedType,
              decoration: InputDecoration(labelText: 'Type'),
              items: ProductType.values.map((type) {
                return DropdownMenuItem<ProductType>(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),
            if (selectedType !=
                ProductType
                    .single) // Show weight and price fields only for non-single types
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      decoration: InputDecoration(labelText: 'Weight (g/lt)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 8), // Add space between weight and price
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                          labelText:
                              'Price (₹)'), // Updated to include rupee sign
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              )
            else // For single type, show only the price input
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                    labelText: 'Price (₹)'), // Updated to include rupee sign
                keyboardType: TextInputType.number,
              ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: addWeightPrice,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: weightPrices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      'Weight: ${weightPrices[index].weight}g, Price: ₹${weightPrices[index].price}'), // Updated to include rupee sign
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCategory != null && selectedType != null) {
                  final product = Product(
                    name: nameController.text,
                    category: selectedCategory!,
                    weightPrices: weightPrices,
                    type: selectedType!,
                  );
                  Provider.of<ProductProvider>(context, listen: false)
                      .addProduct(product);
                  Navigator.pop(context);
                } else {
                  // Show error if category or type not selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select both category and type'),
                    ),
                  );
                }
              },
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
