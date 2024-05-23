import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pixca/view/productDetailingPage.dart';

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
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns in the grid
              crossAxisSpacing: 10.0, // Spacing between columns
              mainAxisSpacing: 10.0, // Spacing between rows
              childAspectRatio: 0.8, // Aspect ratio of each grid item
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var productData = snapshot.data!.docs[index].data();

              // Ensure that productData is of type Map<String, dynamic>
              if (productData is Map<String, dynamic>) {
                // Extract the product details
                String productName =
                    productData['productName'] ?? 'Unnamed Product';
                String productImage = productData['image'] ?? 'No image found';

                List<dynamic> colorList =
                    productData['color'] ?? []; // Assume color is a list

                // Convert colorList to a comma-separated string
                String color = colorList.join(', ');

                String description =
                    productData['description'] ?? 'No description available';
                String brand = productData['brand'] ?? 'Unknown Brand';
                double price = 0.0;
                if (productData['price'] != null) {
                  String priceString = productData['price'].toString();
                  // Remove currency symbols and commas from the price string
                  priceString = priceString.replaceAll(RegExp(r'[$,]'), '');
                  // Parse the price string as a double
                  price = double.tryParse(priceString) ?? 0.0;
                }

                String romString = ''; // Define romString as an empty string

                if (productData['ROM'] != null &&
                    productData['ROM'] is List<dynamic>) {
                  // Ensure that productData['ROM'] is not null and is of type List<dynamic>
                  List<dynamic> rom = productData['ROM']; // Get the ROM list
                  romString = rom.join(
                      ', '); // Join the elements of the list into a single string
                }

                // Build the card widget to display product details
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(productData: productData),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            productImage,
                            height: 120.h,
                          ),
                        )),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(productName,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w900)),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('ROM: $romString GB',
                              style: TextStyle(fontSize: 15)),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('Price: Rs ${price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        // Display price with 2 decimal places
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
              // return GestureDetector(
              //   onTap: () {
              //     Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(productData: productData),))
              //   },
              // )
            },
          );
        },
      ),
    );
  }
}


