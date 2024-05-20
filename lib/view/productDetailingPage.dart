import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cartScreen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailScreen({Key? key, required this.productData})
      : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // double _totalAmount = 0.0;
  bool _isFavorite = false; // Initialize _isFavorite to false

  @override
  void initState() {
    super.initState();
    setState(() {
      fetchFavoriteStatus();
    });
    // Fetch favorite status from Firestore
  }

  // Function to fetch favorite status from Firestore
  Future<void> fetchFavoriteStatus() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productData['pid'])
          .get();

      if (snapshot.exists) {
        setState(() {
          _isFavorite = snapshot['isFavorite'] ?? false;
        });
      }
    } catch (error) {
      print('Error fetching favorite status: $error');
      // Handle error and set _isFavorite to false
      setState(() {
        _isFavorite = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.productData['brand'] ?? ''} '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Display product image
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Image.network(
                widget.productData['image'] ?? '',
                width: MediaQuery.of(context).size.width,
                height: 500,
                fit: BoxFit.fitHeight,
              ),
            ),
            SizedBox(height: 20),
            // Display product details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.productData['productName'] ?? ''}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () async {
                    // Toggle favorite status
                    setState(() {
                      _isFavorite = !_isFavorite; // Use null check operator (!)
                    });
                    // Update Firestore document to mark as favorite
                    await FirebaseFirestore.instance
                        .collection('Products')
                        .doc(widget.productData['pid'])
                        .update({'isFavorite': _isFavorite});
                  },
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Price: \Rs ${widget.productData['price'] ?? ''}',
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(height: 10),
            Text('Color: ${widget.productData['color'] ?? ''}'),
            SizedBox(height: 10),
            Text('RAM: ${widget.productData['ram'] ?? ''}'),
            SizedBox(height: 10),
            Text('ROM: ${widget.productData['ROM'] ?? ''}'),
            SizedBox(height: 10),
            Text(
              'Description: ${widget.productData['description'] ?? ''}',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 70,
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                    ),
                    onPressed: () async {
                      setState(() {});
                    },
                    child: Text(
                      'Book Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: 70,
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700),
                    onPressed: () async {
                      addToCart();
                    },
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to add the product to the cart
  Future<void> addToCart() async {
    try {
      String priceString = widget.productData['price']
          .toString()
          .trim()
          .replaceAll(',', ''); // Trim whitespace and remove commas
      double price = double.parse(priceString);
      double gstRate = 0.18; // GST rate of 18%
      double gstAmount = price * gstRate;

      // Calculate total price without shipping charge
      double totalPriceWithoutShipping = price + gstAmount;

      // Check if the product already exists in the cart
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('pid', isEqualTo: widget.productData['pid'])
          .get();

      if (cartSnapshot.docs.isNotEmpty) {
        // Product already exists in the cart, update quantity and total price
        DocumentSnapshot cartItem = cartSnapshot.docs.first;
        int quantity = cartItem['quantity'] + 1; // Increment quantity
        double totalPrice = totalPriceWithoutShipping * quantity +
            20; // Recalculate total price with shipping charge
        await cartItem.reference
            .update({'quantity': quantity, 'totalPrice': totalPrice});
      } else {
        // Product doesn't exist in the cart, add it
        await FirebaseFirestore.instance.collection('cart').add({
          'pid': widget.productData['pid'],
          // Add product ID
          'productName': widget.productData['productName'],
          'price': price,
          'totalPrice': totalPriceWithoutShipping + 20,
          // Including shipping charge
          'gst': gstAmount,
          'shippingCharge': 20,
          'quantity': 1,
          // Set initial quantity to 1
          // Add other product details as needed
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item added to cart'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartSample(),
          ));
    } catch (error) {
      print('Error adding item to cart: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item to cart'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
