import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String imageURL;
  final String productName;


  ProductDetailPage({required this.imageURL, required this.productName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Detail'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imageURL,
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              productName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Add more details about the product as needed
          ],
        ),
      ),
    );
  }
}
