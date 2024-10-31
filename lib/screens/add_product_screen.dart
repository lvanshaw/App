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
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.teal,
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
                prefixIcon: Icon(Icons.shopping_cart, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                      Icon(Icons.category, color: Colors.teal),
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
                      Icon(Icons.tag, color: Colors.teal),
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

            // Weight and Price Fields
            if (selectedType != ProductType.single)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      decoration: InputDecoration(
                        labelText: 'Weight (g/lt)',
                        prefixIcon: Icon(Icons.scale, color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                        prefixIcon:
                            Icon(Icons.attach_money, color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                  prefixIcon: Icon(Icons.attach_money, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            SizedBox(height: 16),

            // Add Weight and Price Button
            TextButton.icon(
              icon: Icon(Icons.add, color: Colors.teal),
              label: Text(
                'Add Weight and Price',
                style: TextStyle(color: Colors.teal),
              ),
              onPressed: addWeightPrice,
            ),
            SizedBox(height: 8),

            // Display List of Weight and Prices
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: weightPrices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    'Weight: ${weightPrices[index].weight}g, Price: ₹${weightPrices[index].price}',
                  ),
                );
              },
            ),
            SizedBox(height: 16),

            // Save Product Button
            ElevatedButton.icon(
              icon: Icon(Icons.check, color: Colors.white),
              label: Text('Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Product added successfully!'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select both category and type'),
                    ),
                  );
                }
              },
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
    super.key,
    required this.items,
    this.value,
    required this.onChanged,
    required this.hint,
  });

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
            return SizedBox(
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
              style: TextStyle(
                color: value == null ? Colors.grey : Colors.black,
                fontWeight: value == null ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
