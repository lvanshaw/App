import 'package:flutter/material.dart';
import 'package:myapp/screens/delete_products_screen.dart';
import 'package:myapp/screens/download_from_firebase_screen.dart'; // Import the new screen
import 'package:myapp/screens/edit_all_product_screen.dart';
import 'package:myapp/screens/upload_to_firebase_screen.dart';
import 'add_product_screen.dart';
import 'view_records_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            ListTile(
              title: Text('Edit Products'), // New navigation option
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditAllProductsScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Upload to Firebase'), // New navigation option
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UploadToFirebaseScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Delete Products'), // New navigation option
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DeleteProductsScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Download Products'), // New navigation option
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DownloadFromFirebaseScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
