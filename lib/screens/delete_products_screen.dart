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
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          // Check if the products are loaded
          if (productProvider.products.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
              return ListTile(
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
                                Navigator.of(context).pop(); // Close the dialog
                              },
                            ),
                            TextButton(
                              child: Text('Delete'),
                              onPressed: () async {
                                if (product.id != null) {
                                  await productProvider
                                      .deleteProduct(product.id!);
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${product.name} deleted successfully!'),
                                    ),
                                  );
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
              );
            },
          );
        },
      ),
    );
  }
}
