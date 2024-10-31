import 'package:flutter/material.dart';
import 'billing_screen.dart'; // Import the billing screen
import 'delete_products_screen.dart';
import 'download_from_firebase_screen.dart';
import 'edit_all_product_screen.dart';
import 'upload_to_firebase_screen.dart';
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
              decoration: BoxDecoration(color: Colors.green[700]),
              child: Text(
                'Navigation',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.visibility), // Icon for 'View Products'
              title: Text('View Products'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewRecordsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add), // Icon for 'Add Product'
              title: Text('Add Product'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProductScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit), // Icon for 'Edit Products'
              title: Text('Edit Products'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditAllProductsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete), // Icon for 'Delete Products'
              title: Text('Delete Products'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DeleteProductsScreen()),
                );
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.cloud_upload), // Icon for 'Upload to Firebase'
              title: Text('Upload to Firebase'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UploadToFirebaseScreen()),
                );
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.cloud_download), // Icon for 'Download Products'
              title: Text('Download Products'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DownloadFromFirebaseScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt), // Icon for 'Billing'
              title: Text('Billing'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BillingScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
