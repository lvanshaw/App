import 'package:flutter/material.dart';
import 'package:myapp/screens/add_product_screen.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  ProductType? selectedType;
  String? selectedCategory;
  List<WeightPrice> weightPrices = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    selectedType = widget.product.type;
    selectedCategory = widget.product.category;
    weightPrices = List.from(widget.product.weightPrices);
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
      appBar: AppBar(
        title: Text('Edit Product'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Product Name Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                prefixIcon: Icon(Icons.edit, color: Colors.green[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Type Dropdown
            CustomDropdown<ProductType>(
              items: ProductType.values.map((type) {
                return DropdownMenuItem<ProductType>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(Icons.tag, color: Colors.green[700]),
                      SizedBox(width: 8),
                      Text(type.name),
                    ],
                  ),
                );
              }).toList(),
              value: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
              hint: 'Select Type',
            ),
            SizedBox(height: 16),

            // Category Dropdown
            CustomDropdown<String>(
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(Icons.category, color: Colors.green[700]),
                      SizedBox(width: 8),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              value: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              hint: 'Select Category',
            ),
            SizedBox(height: 16),

            // Weight and Price Section
            Text(
              "Weight and Price Details",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 8),
            ...weightPrices.asMap().entries.map((entry) {
              int index = entry.key;
              WeightPrice weightPrice = entry.value;
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(
                          text: weightPrice.weight.toString()),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Weight (g)',
                        prefixIcon:
                            Icon(Icons.balance, color: Colors.green[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        updateWeightPrice(
                            index, double.parse(value), weightPrice.price);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(
                          text: weightPrice.price.toString()),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price (₹)',
                        prefixIcon:
                            Icon(Icons.attach_money, color: Colors.green[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        updateWeightPrice(
                            index, weightPrice.weight, double.parse(value));
                      },
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 10),
            TextButton.icon(
              onPressed: addWeightPriceField,
              icon: Icon(Icons.add, color: Colors.green[700]),
              label: Text(
                "Add Weight and Price",
                style: TextStyle(color: Colors.green[700]),
              ),
            ),
            SizedBox(height: 16),

            // Save Changes Button
            ElevatedButton.icon(
              onPressed: () {
                if (selectedCategory != null && selectedType != null) {
                  final updatedProduct = Product(
                    id: widget.product.id,
                    name: nameController.text,
                    type: selectedType!,
                    category: selectedCategory!,
                    weightPrices: weightPrices,
                  );

                  Provider.of<ProductProvider>(context, listen: false)
                      .updateProduct(updatedProduct);

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select both category and type'),
                    ),
                  );
                }
              },
              icon: Icon(Icons.save, color: Colors.white),
              label: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
