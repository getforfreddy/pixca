import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pixca/view/deliveryLocationMarking.dart';
import 'package:pixca/view/productDetailingPage.dart';

class CartSample extends StatefulWidget {
  const CartSample({Key? key}) : super(key: key);

  @override
  State<CartSample> createState() => _CartSampleState();
}

class _CartSampleState extends State<CartSample> {
  double grandTotal = 0.0;
  String? _userId; // Variable to store the user ID

  Future<void> fetchUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  Future<Map<String, dynamic>> fetchProductDetails(String pid) async {
    final productSnapshot = await FirebaseFirestore.instance.collection('Products').doc(pid).get();
    if (productSnapshot.exists) {
      return productSnapshot.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchProductCartDetails(String pid) async {
    try {
      final cartSnapshot = await FirebaseFirestore.instance.collection('cart').where('pid', isEqualTo: pid).get();
      if (cartSnapshot.docs.isNotEmpty) {
        final cartData = cartSnapshot.docs.first.data() as Map<String, dynamic>;
        return {
          'rom': cartData['rom'],
          'productName': cartData['productName'],
          'price': cartData['price'],
          'quantity': cartData['quantity'],
          'gst': cartData['gst'],
          'shippingCharge': cartData['shippingCharge'],
          'totalPrice': cartData['totalPrice'],
        };
      } else {
        return {};
      }
    } catch (error) {
      print('Error fetching product details: $error');
      return {};
    }
  }

  Future<void> calculateGrandTotal() async {
    if (_userId == null) return;

    final cartSnapshot = await FirebaseFirestore.instance.collection('cart').where('userId', isEqualTo: _userId).get();
    double total = 0.0;
    for (var doc in cartSnapshot.docs) {
      final cartData = doc.data() as Map<String, dynamic>;
      final itemTotalPrice = cartData['totalPrice'] ?? 0.0;
      total += itemTotalPrice;
    }
    setState(() {
      grandTotal = total;
    });
  }

  Future<void> deleteCartItem(String cartItemId) async {
    await FirebaseFirestore.instance.collection('cart').doc(cartItemId).delete();
    calculateGrandTotal();
  }

  @override
  void initState() {
    super.initState();
    fetchUserId().then((_) {
      calculateGrandTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
      ),
      body: _userId == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('cart').where('userId', isEqualTo: _userId).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  final cartItems = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      final cartData = cartItem.data() as Map<String, dynamic>;
                      final productId = cartData['pid'] ?? '';

                      return FutureBuilder<Map<String, dynamic>>(
                        future: fetchProductDetails(productId),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (productSnapshot.hasError) {
                            return Center(
                              child: Text('Error: ${productSnapshot.error}'),
                            );
                          } else {
                            final productData = productSnapshot.data ?? {};
                            final imageUrl = productData['image'] ?? '';
                            final List color = productData['color'] ?? [];
                            final productName = productData['productName'] ?? 'Product Name';
                            final price = cartData['price'] ?? 'N/A';
                            final quantity = cartData['quantity'] ?? 'N/A';
                            final gst = cartData['gst'] ?? '0';
                            final shippingCharge = cartData['shippingCharge'] ?? 'N/A';
                            final totalPrice = cartData['totalPrice'] ?? 'N/A';
                            final rom = cartData['rom'] ?? 'N/A';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                      productData: productData,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          if (imageUrl.isNotEmpty)
                                            Image.network(
                                              imageUrl,
                                              height: 150,
                                              width: 150,
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(productName, style: TextStyle(fontSize: 25)),
                                                if (color.isNotEmpty && index < color.length)
                                                  Text('Color: ${color[index]}', style: TextStyle(fontSize: 15)),
                                                Text('ROM: $rom', style: TextStyle(fontSize: 15)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Column(
                                            children: [
                                              Text('Price      :', style: TextStyle(fontSize: 20)),
                                              Text('QTY        :', style: TextStyle(fontSize: 20)),
                                              Text('GST        :', style: TextStyle(fontSize: 20)),
                                              Text('Shipping :', style: TextStyle(fontSize: 20)),
                                              Text('Total      :', style: TextStyle(fontSize: 20)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 130),
                                          child: Column(
                                            children: [
                                              Text('$price', style: TextStyle(fontSize: 20)),
                                              Text('$quantity', style: TextStyle(fontSize: 20)),
                                              Text('$gst', style: TextStyle(fontSize: 20)),
                                              Text('$shippingCharge', style: TextStyle(fontSize: 20)),
                                              Text('$totalPrice', style: TextStyle(fontSize: 20)),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            deleteCartItem(cartItem.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Grand Total: Rs ${grandTotal.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DeliveryLocationMarkingPage()),
                    );
                  },
                  child: Text('Proceed to Payment'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}