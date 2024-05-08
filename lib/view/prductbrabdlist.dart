import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductListPage extends StatelessWidget {
  final String brand;

  const ProductListPage({Key? key, required this.brand}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('Products')
            .where('brand', isEqualTo: brand)
            .get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products found.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var productData = snapshot.data!.docs[index].data();
              // Ensure that productData is of type Map<String, dynamic>
              if (productData is Map<String, dynamic>) {
                // Extract the product details
                String productName = productData['productName'] ?? 'Unnamed Product';
                List<dynamic> colorList = productData['color'] ?? []; // Assume color is a list

                // Convert colorList to a comma-separated string
                String color = colorList.join(', ');

                String description = productData['description'] ?? 'No description available';
                String brand = productData['brand'] ?? 'Unknown Brand';
                double price = 0.0;
                if (productData['price'] != null) {
                  String priceString = productData['price'].toString();
                  // Remove currency symbols and commas from the price string
                  priceString = priceString.replaceAll(RegExp(r'[$,]'), '');
                  // Parse the price string as a double
                  price = double.tryParse(priceString) ?? 0.0;
                }

                int ram = 0;
                if (productData['ram'] != null) {
                  String ramString = productData['ram'].toString();
                  // Parse the RAM string as an integer
                  ram = int.tryParse(ramString) ?? 0;
                }
// Build the card widget to display product details
                return Card(
                  child: ListTile(
                    title: Text(productName, style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900
                    ),),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Color: $color',  style: TextStyle(
                            fontSize: 15
                        ),),
                        Text('Description: $description',  style: TextStyle(
                            fontSize: 15
                        ),),
                        Text('Brand: $brand',  style: TextStyle(
                            fontSize: 15
                        ),),
                        Text('Price: \$${price.toStringAsFixed(2)}',  style: TextStyle(
                            fontSize: 15
                        ),), // Display price with 2 decimal places
                        Text('RAM: $ram GB'),
                      ],
                    ),
                  ),
                );
              } else {
                // Handle cases where productData is not in the expected format
                return ListTile(
                  title: Text('Invalid Product Data'),
                );
              }
            },
          );

        },
      ),
    );
  }
}
