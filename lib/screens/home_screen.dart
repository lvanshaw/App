import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'view_records_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grocery Store Management')),
      body: Center(child: Text('Welcome to Grocery Store Management')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text('Navigation',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: Text('View Records'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewRecordsScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Add Product'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProductScreen()),
                );
              },
            ),
            // Add more navigation options as needed
          ],
        ),
      ),
    );
  }
}
