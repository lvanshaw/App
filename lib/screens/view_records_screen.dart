import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class ViewRecordsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Records')),
      body: FutureBuilder(
        future: Provider.of<ProductProvider>(context, listen: false)
            .fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              final products = productProvider.products;
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(products[index].name),
                    subtitle: Text(products[index].category),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
