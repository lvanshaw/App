import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  List<BillingItem> billingItems =
      []; // List to hold selected products and their weights
  Product? selectedProduct; // Variable to hold the selected product

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              // Clear the billing items and reset the selected product
              setState(() {
                billingItems.clear(); // Clear all billing items
                selectedProduct = null; // Reset selected product
              });
              Navigator.of(context).pop(); // Go back to the previous screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            final products = productProvider.products;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<Product>(
                  value: selectedProduct, // Set selected value
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Select Product',
                    border: OutlineInputBorder(),
                  ),
                  items: products.map((Product product) {
                    return DropdownMenuItem<Product>(
                      value: product,
                      child: Text(product.name),
                    );
                  }).toList(),
                  onChanged: (product) {
                    if (product != null) {
                      setState(() {
                        selectedProduct = product; // Update selected product
                      });
                      showWeightSelectionDialog(product);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: billingItems.length,
                    itemBuilder: (context, index) {
                      final item = billingItems[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(item.product.name),
                          subtitle: Text(
                              'Weight: ${item.weight}g - Price: ₹${item.totalPrice.toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                billingItems
                                    .removeAt(index); // Remove item from list
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Text(
                  'Total: ₹${calculateTotal().toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Clear the billing items
                    setState(() {
                      billingItems.clear(); // Clear all billing items
                    });
                  },
                  child: const Text('Clear All Billing Items'), // Clear button
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void showWeightSelectionDialog(Product product) {
    final TextEditingController quantityController =
        TextEditingController(text: '1'); // Default quantity is 1
    final TextEditingController weightController =
        TextEditingController(); // For custom weight input

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Weight for ${product.name}'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: [
                    // Weight and price selection
                    Column(
                      children: product.weightPrices.map((weightPrice) {
                        return ListTile(
                          title: Text(
                              "Weight: ${weightPrice.weight}g - Price: ₹${weightPrice.price}"),
                          onTap: () {
                            int quantity =
                                int.tryParse(quantityController.text) ??
                                    1; // Get quantity
                            setState(() {
                              billingItems.add(BillingItem(
                                product: product,
                                weight: weightPrice.weight,
                                totalPrice: weightPrice.price *
                                    quantity, // Calculate total price based on quantity
                              ));
                            });
                            Navigator.of(context)
                                .pop(); // Close the dialog after adding
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Custom weight input only if product type is not 'single'
                    if (product.type != ProductType.single) ...[
                      TextField(
                        controller: weightController,
                        decoration: const InputDecoration(
                          labelText: 'Custom Weight (g)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Quantity input
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'), // Cancel button
            ),
            TextButton(
              onPressed: () {
                // Calculate price based on custom weight
                double? customWeight = double.tryParse(weightController.text);
                if (customWeight != null) {
                  // Find the price for the custom weight
                  final weightPrice = product.weightPrices.firstWhere(
                    (wp) => wp.weight == customWeight,
                    orElse: () => WeightPrice(weight: customWeight, price: 0),
                  );
                  int quantity = int.tryParse(quantityController.text) ??
                      1; // Get quantity
                  double totalPrice = weightPrice.price * quantity;

                  // Add the custom weight billing item
                  setState(() {
                    billingItems.add(BillingItem(
                      product: product,
                      weight: customWeight,
                      totalPrice: totalPrice,
                    ));
                  });
                }
                Navigator.of(context).pop(); // Close the dialog after adding
              },
              child: const Text('Add Custom Weight'),
            ),
          ],
        );
      },
    );
  }

  double calculateTotal() {
    return billingItems.fold(0, (total, item) => total + item.totalPrice);
  }
}

class BillingItem {
  final Product product;
  final double weight;
  final double totalPrice;

  BillingItem({
    required this.product,
    required this.weight,
    required this.totalPrice,
  });
}
