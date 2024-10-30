import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'edit_product_screen.dart';

class ViewRecordsScreen extends StatefulWidget {
  @override
  _ViewRecordsScreenState createState() => _ViewRecordsScreenState();
}

class _ViewRecordsScreenState extends State<ViewRecordsScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Records')),
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

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Search by Product Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          productProvider.searchByName(value); // Trigger search
                        },
                      ),
                    ),
                    ListView.builder(
                      itemCount: products.length,
                      shrinkWrap: true, // Avoid overflow
                      physics:
                          NeverScrollableScrollPhysics(), // Disable scrolling in ListView
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.name,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditProductScreen(
                                                    product: product),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Text("Category: ${product.category}"),
                                SizedBox(height: 10),
                                Text("Weight and Price Details:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                ...product.weightPrices
                                    .map((weightPrice) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Text(
                                              "Weight: ${weightPrice.weight}g - Price: \$${weightPrice.price}"),
                                        )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
