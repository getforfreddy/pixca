import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pixca/view/deliveryLocationMarking.dart';
import 'cartScreen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailScreen({Key? key, required this.productData})
      : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;
  String? _selectedColor; // Variable to store the selected color
  String? _selectedROM; // Variable to store the selected ROM
  String? _userId; // Variable to store the user ID
  int _quantity = 1; // Variable to store the selected quantity
  bool _isInCart = false; // Variable to store the cart status

  @override
  void initState() {
    super.initState();
    fetchUserId(); // Fetch user ID first
    fetchFavoriteStatus(); // Then fetch favorite status
    checkIfInCart(); // Check if the item is in the cart
  }

  // Function to fetch favorite status from Firestore
  Future<void> fetchFavoriteStatus() async {
    try {
      if (_userId != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('favorites')
            .doc(_userId)
            .collection('userFavorites')
            .doc(widget.productData['pid'])
            .get();

        setState(() {
          _isFavorite = snapshot.exists;
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

  // Function to check if the item is already in the cart
  Future<void> checkIfInCart() async {
    try {
      if (_userId != null) {
        QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
            .collection('cart')
            .where('pid', isEqualTo: widget.productData['pid'])
            .where('userId', isEqualTo: _userId)
            .get();

        setState(() {
          _isInCart = cartSnapshot.docs.isNotEmpty;
        });
      }
    } catch (error) {
      print('Error checking cart status: $error');
    }
  }

  Future<void> addToFavorites() async {
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

      // Add the product to favorites collection
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(_userId)
          .collection('userFavorites')
          .doc(widget.productData['pid'])
          .set({
        'userId': _userId, // Save user ID
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item added to favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error adding item to favorites: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item to favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Function to remove the product from favorites
  Future<void> removeFromFavorites() async {
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

      // Remove the product from favorites collection
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(_userId)
          .collection('userFavorites')
          .doc(widget.productData['pid'])
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item removed from favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error removing item from favorites: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove item from favorites'),
          duration: Duration(seconds: 2),
        ),
      );
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
                    if (_isFavorite) {
                      await removeFromFavorites();
                    } else {
                      await addToFavorites();
                    }
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
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
                      if (_selectedColor == null || _selectedROM == null) {
                        // Show alert if no color or ROM is selected
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Mandatory Selection'),
                            content: Text(
                                'Please select both a color and ROM before placing your order.'),
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
                      } else if (_isInCart) {
                        // If the item is already in the cart, navigate to the cart screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CartSample(productData: widget.productData)),
                        );
                      } else {
                        // If the item is not in the cart, add it to the cart
                        await addToCart();
                      }
                    },
                    child: Text(_isInCart ? 'Go to Cart' : 'Add to Cart'),
                  ),
                ),
                SizedBox(height: 20),
                // Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       SizedBox(
                //         height: 70,
                //         width: 150,
                //         child: ElevatedButton(
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: Colors.green.shade700,
                //           ),
                //           onPressed: () async {
                //             if (_selectedColor == null ||
                //                 _selectedROM == null) {
                //               // Show alert if no color or ROM is selected
                //               showDialog(
                //                 context: context,
                //                 builder: (context) => AlertDialog(
                //                   title: Text('Mandatory Selection'),
                //                   content: Text(
                //                       'Please select both a color and ROM before placing your order.'),
                //                   actions: [
                //                     TextButton(
                //                       onPressed: () {
                //                         Navigator.pop(context);
                //                       },
                //                       child: Text('OK'),
                //                     ),
                //                   ],
                //                 ),
                //               );
                //             } else {
                //               await placeOrder();
                //             }
                //           },
                //           child: Text(
                //             'Buy Now',
                //             style: TextStyle(color: Colors.white),
                //           ),
                //         ),
                //       ),
                //     ])

                // Row(
                //   children: [
                //     IconButton(
                //       icon: Icon(Icons.remove),
                //       onPressed: () {
                //         setState(() {
                //           if (_quantity > 1) {
                //             _quantity--;
                //           }
                //         });
                //       },
                //     ),
                //     Text(
                //       '$_quantity',
                //       style: TextStyle(fontSize: 18),
                //     ),
                //     IconButton(
                //       icon: Icon(Icons.add),
                //       onPressed: () {
                //         setState(() {
                //           _quantity++;
                //         });
                //       },
                //     ),
                //   ],
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> placeOrder() async {
  //   try {
  //     if (_userId == null) {
  //       // Handle the case where the user ID is not available
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('User not logged in'),
  //           duration: Duration(seconds: 2),
  //         ),
  //       );
  //       return;
  //     }
  //
  //     // Parsing and calculating price and GST
  //     String priceString = widget.productData['price']
  //         .toString()
  //         .trim()
  //         .replaceAll(',', ''); // Trim whitespace and remove commas
  //     double price = double.parse(priceString);
  //     double gstRate = 0.18; // GST rate of 18%
  //     double gstAmount = price * gstRate;
  //
  //     // Calculate total price without shipping charge
  //     double totalPriceWithoutShipping = price + gstAmount;
  //
  //     // Generate orderId
  //     String orderId = FirebaseFirestore.instance.collection('orders').doc().id;
  //
  //     // Check if the product already exists in the orders
  //     QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
  //         .collection('orders')
  //         .where('pid', isEqualTo: widget.productData['pid'])
  //         .where('userId', isEqualTo: _userId)
  //         .where('color', isEqualTo: _selectedColor)
  //         .where('rom', isEqualTo: _selectedROM)
  //         .get();
  //
  //     if (orderSnapshot.docs.isNotEmpty) {
  //       // Product already exists in the orders, update quantity and total price
  //       DocumentSnapshot orderItem = orderSnapshot.docs.first;
  //       int quantity = orderItem['quantity'] + 1; // Increment quantity
  //       double totalPrice = totalPriceWithoutShipping * quantity + 20; // Recalculate total price with shipping charge
  //       await orderItem.reference.update({'quantity': quantity, 'totalPrice': totalPrice});
  //     } else {
  //       // Product doesn't exist in the orders, add it
  //       DocumentReference orderRef = await FirebaseFirestore.instance.collection('orders').add({
  //         'orderId': orderId, // Assign orderId
  //         'userId': _userId,
  //         'pid': widget.productData['pid'],
  //         'productName': widget.productData['productName'],
  //         'price': price,
  //         'totalPrice': totalPriceWithoutShipping + 20, // Including shipping charge
  //         'gst': gstAmount,
  //         'shippingCharge': 20,
  //         'quantity': 1,
  //         'color': _selectedColor, // Save the selected color
  //         'rom': _selectedROM, // Save the selected ROM
  //         'orderStatus': 'Pending', // Initial order status
  //       });
  //
  //       // Inform user to choose address and navigate to the address page
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Choose your address..'),
  //           duration: Duration(seconds: 2),
  //         ),
  //       );
  //
  //       // Navigate to address saving page and pass order details
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => DeliveryLocationMarkingPage(
  //             productData: widget.productData,
  //             orderId: orderId, // Pass orderId to the next screen
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (error) {
  //     print('Failed to place order: $error');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to place order'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }
  //
  // Future<void> placeOrder() async {
  //   try {
  //     if (_userId == null) {
  //       // Handle the case where the user ID is not available
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('User not logged in'),
  //           duration: Duration(seconds: 2),
  //         ),
  //       );
  //       return;
  //     }
  //
  //     // Retrieve cart items for the user
  //     QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
  //         .collection('cart')
  //         .where('userId', isEqualTo: _userId)
  //         .get();
  //
  //     if (cartSnapshot.docs.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('No items in cart to place order'),
  //           duration: Duration(seconds: 2),
  //         ),
  //       );
  //       return;
  //     }
  //
  //     // Create a batch to perform multiple write operations
  //     WriteBatch batch = FirebaseFirestore.instance.batch();
  //
  //     for (QueryDocumentSnapshot cartDoc in cartSnapshot.docs) {
  //       Map<String, dynamic> cartData = cartDoc.data() as Map<String, dynamic>;
  //       // Generate a unique order ID
  //       DocumentReference orderRef =
  //           FirebaseFirestore.instance.collection('orders').doc();
  //
  //       // Add the cart item to the orders collection with the order ID
  //       batch.set(orderRef, {
  //         'orderId': orderRef.id,
  //         'pid': cartData['pid'],
  //         'brand': cartData['brand'],
  //         'productName': cartData['productName'],
  //         'price': cartData['price'],
  //         'color': cartData['color'],
  //         'ROM': cartData['ROM'],
  //         'userId': _userId,
  //         'quantity': cartData['quantity'],
  //         'image': cartData['image'],
  //         'orderTimestamp': FieldValue.serverTimestamp(),
  //       });
  //
  //       // Remove the item from the cart
  //       batch.delete(cartDoc.reference);
  //     }
  //
  //     // Commit the batch
  //     await batch.commit();
  //
  //     // Update the cart status and navigate to the order confirmation screen
  //     setState(() {
  //       _isInCart = false;
  //     });
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => DeliveryLocationMarkingPage(
  //               productData: widget.productData,
  //               orderId: widget.productData['orderId'])),
  //     );
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Items successfully ordered'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   } catch (error) {
  //     print('Error while ordering items: $error');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to order items'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }

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

      await FirebaseFirestore.instance.collection('cart').add({
        'pid': widget.productData['pid'],
        'brand': widget.productData['brand'],
        'productName': widget.productData['productName'],
        'price': widget.productData['price'],
        'color': _selectedColor,
        'ROM': _selectedROM,
        'userId': _userId,
        'quantity': _quantity,
        'image': widget.productData['image'],
      });

      // Update the cart status and navigate to the cart screen
      setState(() {
        _isInCart = true;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CartSample(productData: widget.productData)),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item added to cart'),
          duration: Duration(seconds: 2),
        ),
      );
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
