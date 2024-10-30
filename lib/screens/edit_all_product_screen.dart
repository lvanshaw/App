import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart'; // Adjust the import path as needed
import '../models/product.dart'; // Ensure this import is correct for your Product model

class EditAllProductsScreen extends StatefulWidget {
  @override
  _EditAllProductsScreenState createState() => _EditAllProductsScreenState();
}

class _EditAllProductsScreenState extends State<EditAllProductsScreen> {
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> categoryControllers = [];
  List<List<TextEditingController>> weightControllers = [];
  List<List<TextEditingController>> priceControllers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit All Products')),
      body: FutureBuilder(
        future: Provider.of<ProductProvider>(context, listen: false)
            .loadProducts(), // Ensure this method exists
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              final products = productProvider.products;

              // Initialize controllers when products are loaded
              if (nameControllers.isEmpty) {
                nameControllers = List.generate(
                    products.length,
                    (index) =>
                        TextEditingController(text: products[index].name));
                categoryControllers = List.generate(
                    products.length,
                    (index) =>
                        TextEditingController(text: products[index].category));
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
                          TextField(
                            controller: categoryControllers[index],
                            decoration: InputDecoration(
                              labelText: "Category",
                            ),
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
                                        labelText: "Price (\$)",
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
                              // Add new weight and price fields
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
      // Save Changes Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final productProvider =
              Provider.of<ProductProvider>(context, listen: false);
          for (int index = 0;
              index < productProvider.products.length;
              index++) {
            final product = productProvider.products[index];

            // Create updated product with new values
            Product updatedProduct = Product(
              id: product.id, // Assuming you have an id field
              name: nameControllers[index].text,
              category: categoryControllers[index].text,
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

            // Call your provider method to update the product in the database
            productProvider.updateProduct(updatedProduct);
          }
          // Optionally show a snackbar or dialog to indicate success
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
    // Clean up the controllers
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
    for (var controller in categoryControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
