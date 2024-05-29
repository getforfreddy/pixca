// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:pixca/view/productDetailingPage.dart';
// import 'deliveryLocationMarking.dart';
//
// class CartSample extends StatefulWidget {
//   final Map<String, dynamic> productData;
//
//   const CartSample({Key? key, required this.productData}) : super(key: key);
//
//   @override
//   State<CartSample> createState() => _CartSampleState();
// }
//
// class _CartSampleState extends State<CartSample> {
//   int itemCount = 1; // Initial item count
//   double grandTotal = 0.0;
//   String? _userId;
//   String _selectedColor = '';
//   String _selectedROM = '';
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUserId().then((_) {
//       calculateGrandTotal();
//     });
//   }
//
//   Future<void> fetchUserId() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       setState(() {
//         _userId = user.uid;
//       });
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchProductDetails(String pid) async {
//     try {
//       // Fetch product details from the cart
//       final cartSnapshot =
//       await FirebaseFirestore.instance.collection('cart').doc(pid).get();
//
//       if (cartSnapshot.exists) {
//         final cartData = cartSnapshot.data() as Map<String, dynamic>;
//         return cartData; // Return cart data as product details
//       } else {
//         return {}; // Return an empty map if the cart item doesn't exist
//       }
//     } catch (error) {
//       print('Error fetching product details: $error');
//       return {}; // Return an empty map in case of an error
//     }
//   }
//
//
//   Future<void> updateCartQuantity(String cartItemId, int quantity) async {
//     final cartDoc =
//         FirebaseFirestore.instance.collection('cart').doc(cartItemId);
//     final cartSnapshot = await cartDoc.get();
//     if (cartSnapshot.exists) {
//       final cartData = cartSnapshot.data() as Map<String, dynamic>;
//       final price = cartData['price'] ?? 0.0;
//       final gst = cartData['gst'] ?? 0.0;
//       final shippingCharge = cartData['shippingCharge'] ?? 0.0;
//       final totalPrice = (price * quantity) + gst + shippingCharge;
//
//       await cartDoc.update({
//         'quantity': quantity,
//         'totalPrice': totalPrice,
//       });
//
//       calculateGrandTotal();
//     }
//   }
//
//   Future<void> calculateGrandTotal() async {
//     if (_userId == null) return;
//
//     final cartSnapshot = await FirebaseFirestore.instance
//         .collection('cart')
//         .where('userId', isEqualTo: _userId)
//         .get();
//     double total = 0.0;
//     for (var doc in cartSnapshot.docs) {
//       final cartData = doc.data() as Map<String, dynamic>;
//       final itemPrice = cartData['price'] ?? 0.0;
//       final itemCount = cartData['quantity'] ?? 1;
//       final itemTotalPrice = itemPrice * itemCount;
//       total += itemTotalPrice;
//     }
//     setState(() {
//       grandTotal = total;
//     });
//   }
//
//   Future<void> deleteCartItem(String cartItemId) async {
//     await FirebaseFirestore.instance
//         .collection('cart')
//         .doc(cartItemId)
//         .delete();
//     calculateGrandTotal();
//   }
//
//   Future<String> createOrder() async {
//     // Implement your order creation logic here and return the orderId
//     final orderId = FirebaseFirestore.instance.collection('orders').doc().id;
//     return orderId;
//   }
//
//   Future<void> placeOrder(String orderId) async {
//     try {
//       if (_userId == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('User not logged in'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//         print('User not logged in'); // For debugging
//         return;
//       }
//
//       // Fetch all items in the cart for the current user
//       final cartSnapshot = await FirebaseFirestore.instance
//           .collection('cart')
//           .where('userId', isEqualTo: _userId)
//           .get();
//
//       if (cartSnapshot.docs.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Cart is empty'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//         print('Cart is empty'); // For debugging
//         return;
//       }
//
//       // Iterate through each item in the cart and add it to the orders collection
//       for (var cartItem in cartSnapshot.docs) {
//         final cartData = cartItem.data();
//         final productId = cartData['pid'];
//
//         // Retrieve product details
//         final productDetails = await fetchProductDetails(productId);
//
//         // Extract price from cart data
//         final rawPriceString = cartData['price'].toString();
//         double price;
//         try {
//           price = double.parse(rawPriceString);
//         } catch (e) {
//           print('Error parsing price string: $e');
//           continue; // Skip adding this item to the orders collection
//         }
//
//         final gstRate = 0.18; // GST rate of 18%
//         final gstAmount = price * gstRate;
//
//         // Calculate total price without shipping charge
//         final totalPriceWithoutShipping = price + gstAmount;
//
//         // Add item to the orders collection
//         await FirebaseFirestore.instance.collection('orders').add({
//           'orderId': orderId,
//           'userId': _userId,
//           'pid': productId,
//           'productName': productDetails['productName'],
//           'price': price,
//           'totalPrice': totalPriceWithoutShipping + 20,
//           // Including shipping charge
//           'gst': gstAmount,
//           'shippingCharge': 20,
//           'quantity': cartData['quantity'],
//           'color': cartData['color'],
//           'rom': cartData['rom'],
//           'orderStatus': 'Pending',
//           'status': 'Pending',
//         });
//
//         // Delete the item from the cart since it's been added to the orders
//         // await FirebaseFirestore.instance
//         //     .collection('cart')
//         //     .doc(cartItem.id)
//         //     .delete();
//       }
//
//       // Show a success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Choose your address'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       final productData = widget.productData;
//
//       // Navigate to the next page
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => DeliveryLocationMarkingPage(
//             orderId: orderId,
//             productData: productData,
//           ),
//         ),
//       );
//     } catch (error) {
//       print('Failed to place order: $error');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to place order'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Cart"),
//       ),
//       body: _userId == null
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Expanded(
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection('cart')
//                         .where('userId', isEqualTo: _userId)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(
//                           child: CircularProgressIndicator(),
//                         );
//                       } else if (snapshot.hasError) {
//                         return Center(
//                           child: Text('Error: ${snapshot.error}'),
//                         );
//                       } else if (!snapshot.hasData ||
//                           snapshot.data!.docs.isEmpty) {
//                         return Center(
//                           child: Text('Your cart is empty'),
//                         );
//                       } else {
//                         final cartItems = snapshot.data!.docs;
//                         return ListView.builder(
//                           itemCount: cartItems.length,
//                           itemBuilder: (context, index) {
//                             final cartItem = cartItems[index];
//                             final cartData =
//                                 cartItem.data() as Map<String, dynamic>;
//                             final productId = cartData['pid'] ?? '';
//
//                             return FutureBuilder<Map<String, dynamic>>(
//                               future: fetchProductDetails(productId),
//                               builder: (context, productSnapshot) {
//                                 if (productSnapshot.connectionState ==
//                                     ConnectionState.waiting) {
//                                   return Center(
//                                     child: CircularProgressIndicator(),
//                                   );
//                                 } else if (productSnapshot.hasError) {
//                                   return Center(
//                                     child:
//                                         Text('Error: ${productSnapshot.error}'),
//                                   );
//                                 } else {
//                                   final productData =
//                                       productSnapshot.data ?? {};
//                                   final imageUrl = productData['image'] ?? '';
//                                   final List color = productData['color'] ?? [];
//                                   final productName =
//                                       productData['productName'] ??
//                                           'Product Name';
//                                   final price = cartData['price'] ?? 'N/A';
//                                   final quantity =
//                                       cartData['quantity'] ?? 'N/A';
//                                   final gst = cartData['gst'] ?? '0';
//                                   final shippingCharge =
//                                       cartData['shippingCharge'] ?? 'N/A';
//                                   final totalPrice =
//                                       cartData['totalPrice'] ?? 'N/A';
//                                   final rom = cartData['rom'] ?? 'N/A';
//                                   return GestureDetector(
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(18.0),
//                                       child: Card(
//                                         child: Row(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.end,
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceEvenly,
//                                           children: [
//                                             if (imageUrl.isNotEmpty)
//                                               Padding(
//                                                 padding:
//                                                     const EdgeInsets.all(8.0),
//                                                 child: Image.network(
//                                                   imageUrl,
//                                                   height: 150,
//                                                   width: 150,
//                                                 ),
//                                               ),
//                                             Column(
//                                               children: [
//                                                 Text(productName,
//                                                     style: TextStyle(
//                                                         fontSize: 25)),
//                                                 if (color.isNotEmpty &&
//                                                     index < color.length)
//                                                   Text('Color: ${color[index]}',
//                                                       style: TextStyle(
//                                                           fontSize: 15)),
//                                                 Text('ROM: $rom',
//                                                     style: TextStyle(
//                                                         fontSize: 15)),
//                                                 Text('price: $price',
//                                                     style: TextStyle(
//                                                         fontSize: 15)),
//                                                 Row(
//                                                   children: [
//                                                     IconButton(
//                                                       onPressed: () {
//                                                         setState(() {
//                                                           itemCount++;
//                                                           updateCartQuantity(
//                                                               cartItem.id,
//                                                               itemCount); // Update quantity in the cart
//                                                         });
//                                                       },
//                                                       icon: Icon(Icons.add),
//                                                     ),
//                                                     Text(
//                                                       '$itemCount',
//                                                       style: TextStyle(
//                                                           fontSize: 20),
//                                                     ),
//                                                     IconButton(
//                                                       onPressed: () {
//                                                         setState(() {
//                                                           if (itemCount > 1) {
//                                                             itemCount--;
//                                                             updateCartQuantity(
//                                                                 cartItem.id,
//                                                                 itemCount); // Update quantity in the cart
//                                                           }
//                                                         });
//                                                       },
//                                                       icon: Icon(Icons.remove),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                             IconButton(
//                                                 onPressed: () {
//                                                   deleteCartItem(cartItem.id);
//                                                 },
//                                                 icon: Icon(CupertinoIcons
//                                                     .delete_simple)),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               ProductDetailScreen(
//                                             productData: productData,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   );
//                                 }
//                               },
//                             );
//                           },
//                         );
//                       }
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Grand Total: Rs ${grandTotal.toStringAsFixed(2)}',
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: () async {
//                           // Create an order and pass the orderId and product data to the next screen
//                           final orderId = await createOrder();
//
//                           await placeOrder(orderId);
//                         },
//                         child: Text('Continue'),
//                         style: ElevatedButton.styleFrom(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 50, vertical: 15),
//                           textStyle: TextStyle(fontSize: 20),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }