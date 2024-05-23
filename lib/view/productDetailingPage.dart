import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pixca/view/deliveryLocationMarking.dart';
import 'cartScreen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailScreen({Key? key, required this.productData}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;
  String? _selectedColor; // Variable to store the selected color
  String? _selectedROM; // Variable to store the selected ROM
  String? _userId; // Variable to store the user ID

  @override
  void initState() {
    super.initState();
    fetchFavoriteStatus();
    fetchUserId();
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
      setState(() {
        _isFavorite = false;
      });
    }
  }

  // Function to fetch the current user ID
  Future<void> fetchUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
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
              'Price: Rs ${widget.productData['price'] ?? ''}',
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(height: 10),
            Text('Color:'),
            Wrap(
              spacing: 5.w,
              children: (widget.productData['color'] as List<dynamic> ?? [])
                  .map<Widget>((color) {
                return Material(
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _selectedColor = color.toString(); // Set selected color
                      });
                    },
                    child: Chip(
                      label: Text(
                        color.toString(),
                      ),
                      backgroundColor: _selectedColor == color.toString()
                          ? Colors.green.shade200
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 10),
            Text('RAM: ${widget.productData['ram'] ?? ''}'),
            SizedBox(height: 10),
            Text('ROM: '),
            Wrap(
              spacing: 5.w,
              children: (widget.productData['ROM'] as List<dynamic> ?? [])
                  .map<Widget>((rom) {
                return Material(
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _selectedROM = rom.toString(); // Set selected ROM
                      });
                    },
                    child: Chip(
                      label: Text(
                        rom.toString(),
                      ),
                      backgroundColor: _selectedROM == rom.toString()
                          ? Colors.green.shade200
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeliveryLocationMarkingPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Buy Now',
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
                      if (_selectedColor == null || _selectedROM == null) {
                        // Show alert if no color or ROM is selected
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Mandatory Selection'),
                            content: Text(
                                'Please select both a color and ROM before adding to the cart.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        addToCart();
                      }
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
      if (_userId == null) {
        // Handle the case where the user ID is not available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not logged in'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

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
          .where('userId', isEqualTo: _userId)
          .where('color', isEqualTo: _selectedColor)
          .where('rom', isEqualTo: _selectedROM)
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
          'userId': _userId,
          'pid': widget.productData['pid'],
          // Add product ID
          'productName': widget.productData['productName'],
          'price': price,
          'totalPrice': totalPriceWithoutShipping + 20,
          // Including shipping charge
          'gst': gstAmount,
          'shippingCharge': 20,
          'quantity': 1,
          'color': _selectedColor, // Save the selected color
          'rom': _selectedROM, // Save the selected ROM
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
