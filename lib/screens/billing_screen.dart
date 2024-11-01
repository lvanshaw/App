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
  List<BillingItem> billingItems = [];
  Product? selectedProduct;

  @override
  Widget build(BuildContext context) {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              setState(() {
                billingItems.clear();
                selectedProduct = null;
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<Product>(
              value: selectedProduct,
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
                    selectedProduct = product;
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
                        'Weight: ${item.weight}g - Price: ₹${item.totalPrice.toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            billingItems.removeAt(index);
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  billingItems.clear();
                });
              },
              child: const Text('Clear All Billing Items'),
            ),
          ],
        ),
      ),
    );
  }

  void showWeightSelectionDialog(Product product) {
    final TextEditingController quantityController =
        TextEditingController(text: '1');
    final TextEditingController weightController = TextEditingController();

    // Sort weightPrices by weight in ascending order
    product.weightPrices.sort((a, b) => a.weight.compareTo(b.weight));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Weight for ${product.name}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Column(
                  children: product.weightPrices.map((weightPrice) {
                    return ListTile(
                      title: Text(
                          "Weight: ${weightPrice.weight}g - Price: ₹${weightPrice.price}"),
                      onTap: () {
                        int quantity =
                            int.tryParse(quantityController.text) ?? 1;
                        if (quantity <= 0) return;

                        // Add selected weight immediately
                        setState(() {
                          billingItems.add(BillingItem(
                            product: product,
                            weight: weightPrice.weight.toDouble(),
                            totalPrice: weightPrice.price * quantity,
                          ));
                        });
                        Navigator.of(context)
                            .pop(); // Close the dialog after adding
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
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
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextButton(
                    onPressed: () {
                      double? customWeight =
                          double.tryParse(weightController.text);
                      int quantity = int.tryParse(quantityController.text) ?? 1;

                      if (customWeight != null &&
                          customWeight > 0 &&
                          quantity > 0) {
                        WeightPrice? closestWeightPrice;
                        for (var wp in product.weightPrices) {
                          if (wp.weight <= customWeight) {
                            closestWeightPrice = wp;
                          }
                        }

                        if (closestWeightPrice != null) {
                          double pricePerGram = closestWeightPrice.price /
                              closestWeightPrice.weight;
                          double totalPrice =
                              pricePerGram * customWeight * quantity;

                          setState(() {
                            billingItems.add(BillingItem(
                              product: product,
                              weight: customWeight,
                              totalPrice: totalPrice,
                            ));
                          });
                        }
                      }
                      Navigator.of(context)
                          .pop(); // Close the dialog after adding
                    },
                    child: const Text('Add Custom Weight'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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
