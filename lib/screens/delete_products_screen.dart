import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class DeleteProductsScreen extends StatefulWidget {
  const DeleteProductsScreen({super.key});

  @override
  _DeleteProductsScreenState createState() => _DeleteProductsScreenState();
}

class _DeleteProductsScreenState extends State<DeleteProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Load products when the screen initializes
    Provider.of<ProductProvider>(context, listen: false).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Products'),
        backgroundColor: Colors.green[700],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          // Check if products are loaded
          if (productProvider.products.isEmpty) {
            return Center(child: Text('No products found.'));
          }

          return ListView.builder(
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: ListTile(
                  leading: Icon(Icons.shopping_cart, color: Colors.green[700]),
                  title: Text(product.name),
                  subtitle: Text('Category: ${product.category}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Deletion'),
                            content: Text(
                                'Are you sure you want to delete ${product.name}?'),
                            actions: [
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                              ),
                              TextButton(
                                child: Text('Delete'),
                                onPressed: () async {
                                  if (product.id != null) {
                                    // Show loading indicator while deleting
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Deleting...'),
                                      ),
                                    );
                                    await productProvider
                                        .deleteProduct(product.id!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${product.name} deleted successfully!'),
                                      ),
                                    );
                                    // Reload products after deletion
                                    Provider.of<ProductProvider>(context,
                                            listen: false)
                                        .loadProducts();
                                  } else {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Error: Product ID is null'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
