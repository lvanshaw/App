import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart'; // Ensure ProductType is imported from product.dart
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
              decoration: InputDecoration(
                labelText: 'Product Name',
                prefixIcon: Icon(Icons.shopping_cart), // Icon for Product Name
              ),
            ),
            SizedBox(height: 16),
            // Category Dropdown
            CustomDropdown<String>(
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(Icons.category), // Icon for category
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
            // Type Dropdown
            CustomDropdown<ProductType>(
              items: ProductType.values.map((type) {
                return DropdownMenuItem<ProductType>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(Icons.tag), // Icon for type
                      SizedBox(width: 8),
                      Text(type.name), // Access the extension method
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
            if (selectedType != ProductType.single)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      decoration: InputDecoration(
                        labelText: 'Weight (g/lt)',
                        prefixIcon: Icon(Icons.scale), // Icon for weight
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Price (₹)',
                        prefixIcon: Icon(Icons.money), // Icon for price
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              )
            else
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price (₹)',
                  prefixIcon: Icon(Icons.money), // Icon for price
                ),
                keyboardType: TextInputType.number,
              ),
            SizedBox(height: 16),
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
                      'Weight: ${weightPrices[index].weight}g, Price: ₹${weightPrices[index].price}'),
                );
              },
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              // Add icon to the button
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select both category and type'),
                    ),
                  );
                }
              },
              icon: Icon(Icons.check), // Icon for the button
              label: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String hint;

  const CustomDropdown({
    Key? key,
    required this.items,
    this.value,
    required this.onChanged,
    required this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return Container(
              height: 300,
              child: ListView(
                children: items.map((item) {
                  return InkWell(
                    onTap: () {
                      onChanged(item.value);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      child: item.child,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null ? value.toString() : hint,
              style:
                  TextStyle(color: value == null ? Colors.grey : Colors.black),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
