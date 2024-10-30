import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class EditAllProductsScreen extends StatefulWidget {
  const EditAllProductsScreen({super.key});

  @override
  _EditAllProductsScreenState createState() => _EditAllProductsScreenState();
}

class _EditAllProductsScreenState extends State<EditAllProductsScreen> {
  List<TextEditingController> nameControllers = [];
  List<List<TextEditingController>> weightControllers = [];
  List<List<TextEditingController>> priceControllers = [];

  List<ProductType?> selectedTypes = [];
  List<String?> selectedCategories = [];

  final List<String> categories = ['Category A', 'Category B', 'Category C'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit All Products')),
      body: FutureBuilder(
        future:
            Provider.of<ProductProvider>(context, listen: false).loadProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              final products = productProvider.products;

              if (nameControllers.isEmpty) {
                nameControllers = List.generate(
                    products.length,
                    (index) =>
                        TextEditingController(text: products[index].name));

                selectedCategories = List.generate(
                    products.length, (index) => products[index].category);

                selectedTypes = List.generate(
                    products.length, (index) => products[index].type);

                weightControllers = List.generate(
                    products.length,
                    (index) => List.generate(
                        products[index].weightPrices.length,
                        (weightIndex) => TextEditingController(
                            text: products[index]
                                .weightPrices[weightIndex]
                                .weight
                                .toString())));
                priceControllers = List.generate(
                    products.length,
                    (index) => List.generate(
                        products[index].weightPrices.length,
                        (weightIndex) => TextEditingController(
                            text: products[index]
                                .weightPrices[weightIndex]
                                .price
                                .toString())));
              }

              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Product ${index + 1}",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: nameControllers[index],
                            decoration: InputDecoration(
                              labelText: "Product Name",
                            ),
                          ),
                          SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: selectedCategories[index] ??
                                categories[0], // Fallback to first category
                            decoration: InputDecoration(labelText: "Category"),
                            items: categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategories[index] =
                                    value!; // No need to check for null here
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          DropdownButtonFormField<ProductType>(
                            value: selectedTypes[index] ??
                                ProductType.values[0], // Fallback to first type
                            decoration: InputDecoration(labelText: "Type"),
                            items: ProductType.values.map((type) {
                              return DropdownMenuItem<ProductType>(
                                value: type,
                                child: Text(type.toString().split('.').last),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedTypes[index] =
                                    value!; // No need to check for null here
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          Text("Weight and Price Details:"),
                          ...List.generate(product.weightPrices.length,
                              (weightIndex) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: weightControllers[index]
                                          [weightIndex],
                                      decoration: InputDecoration(
                                        labelText: "Weight (g)",
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: priceControllers[index]
                                          [weightIndex],
                                      decoration: InputDecoration(
                                        labelText:
                                            "Price (₹)", // Use ₹ for price
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                weightControllers[index]
                                    .add(TextEditingController());
                                priceControllers[index]
                                    .add(TextEditingController());
                              });
                            },
                            child: Text('Add Weight/Price'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final productProvider =
              Provider.of<ProductProvider>(context, listen: false);
          for (int index = 0;
              index < productProvider.products.length;
              index++) {
            final product = productProvider.products[index];

            Product updatedProduct = Product(
              id: product.id,
              name: nameControllers[index].text,
              category:
                  selectedCategories[index]! ?? '', // Handle null if necessary
              type: selectedTypes[index]! ??
                  ProductType.single, // Handle null if necessary
              weightPrices:
                  List.generate(weightControllers[index].length, (weightIndex) {
                return WeightPrice(
                  weight:
                      double.parse(weightControllers[index][weightIndex].text),
                  price:
                      double.parse(priceControllers[index][weightIndex].text),
                );
              }),
            );

            productProvider.updateProduct(updatedProduct);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Products updated successfully!')),
          );
        },
        child: Icon(Icons.save),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in nameControllers) {
      controller.dispose();
    }
    for (var controllerList in weightControllers) {
      for (var controller in controllerList) {
        controller.dispose();
      }
    }
    for (var controllerList in priceControllers) {
      for (var controller in controllerList) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}
