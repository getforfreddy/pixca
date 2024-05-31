import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pixca/view/productDetailingPage.dart';
import 'deliveryLocationMarking.dart';

class CartSample extends StatefulWidget {
  final Map<String, dynamic> productData;

  const CartSample({Key? key, required this.productData}) : super(key: key);

  @override
  State<CartSample> createState() => _CartSampleState();
}

class _CartSampleState extends State<CartSample> {
  int itemCount = 1; // Initial item count
  double grandTotal = 0.0;
  String? _userId;
  String _selectedColor = '';
  String _selectedROM = '';

  @override
  void initState() {
    super.initState();
    fetchUserId().then((_) {
      calculateGrandTotal();
    });
  }

  Future<String> createOrder() async {
    // Implement your order creation logic here and return the orderId
    final orderId = FirebaseFirestore.instance.collection('orders').doc().id;
    return orderId;
  }

  Future<void> deleteCartItem(String cartItemId) async {
    await FirebaseFirestore.instance
        .collection('cart') // Ensure this is the correct collection
        .doc(cartItemId)
        .delete();
    calculateGrandTotal();
  }

  Future<void> calculateGrandTotal() async {
    if (_userId == null) return;

    final cartSnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: _userId)
        .get();
    double total = 0.0;
    for (var doc in cartSnapshot.docs) {
      final cartData = doc.data() as Map<String, dynamic>;
      final rawItemPrice = cartData['price'];

      // Remove commas from the price string
      final priceString = rawItemPrice.replaceAll(',', '');

      // Convert the price string to double
      double itemPrice = double.tryParse(priceString) ?? 0.0;

      final itemCount = cartData['quantity'] ?? 1;
      print('Item Price: $itemPrice, Item Count: $itemCount');
      final itemTotalPrice = itemPrice * itemCount;
      total += itemTotalPrice;
    }

    setState(() {
      grandTotal = total;
      print(grandTotal);
    });
  }

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
        title: Text("Cart"),
      ),
      body: _userId == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('cart')
                        .where('userId', isEqualTo: _userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('Your cart is empty'));
                      } else {
                        final cartItems = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final cartItem = cartItems[index];
                            final cartData =
                                cartItem.data() as Map<String, dynamic>;
                            final productId = cartData['pid'];
                            final quantity = cartData['quantity'];
                            final price = cartData['price'];
                            final productName = cartData['productName'];
                            // Handling the color field
                            dynamic colorData = cartData['color'];
                            List<String> colorList = [];
                            if (colorData is String) {
                              // If colorData is a string, split it by comma to create a list
                              colorList = colorData.split(',');
                            } else if (colorData is List) {
                              // If colorData is already a list, assign it directly
                              colorList = List<String>.from(colorData);
                            }
                            final image = cartData['image'];
                            final rom = cartData['rom'];
                            return GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Card(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.network(
                                          image,
                                          height: 150,
                                          width: 150,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            productName,
                                            style: TextStyle(fontSize: 25),
                                          ),
                                          Text(colorList[0],
                                              style: TextStyle(fontSize: 25)),
                                          Text('ROM: $rom',
                                              style: TextStyle(fontSize: 15)),
                                          Text('price: $price',
                                              style: TextStyle(fontSize: 15)),
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  setState(() {});
                                                },
                                                icon: Icon(Icons.add),
                                              ),
                                              Text(
                                                '$itemCount',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    if (itemCount > 1) {}
                                                  });
                                                },
                                                icon: Icon(Icons.remove),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            deleteCartItem(cartItem.id);
                                          },
                                          icon: Icon(
                                              CupertinoIcons.delete_simple)),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                // Navigate to product details if needed
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
                        'Grand Total: Rs ${grandTotal}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          // Generate a unique order ID
                          final orderId = await createOrder();

                          // Retrieve all items from the user's cart
                          final cartSnapshot = await FirebaseFirestore.instance
                              .collection('cart')
                              .where('userId', isEqualTo: _userId)
                              .get();

                          // Iterate over each item in the cart
                          for (var cartItem in cartSnapshot.docs) {
                            // Get the cart item data
                            final cartData =
                                cartItem.data() as Map<String, dynamic>;
                            final productId = cartData['pid'];
                            final price = cartData['price'];
                            final quantity = cartData['quantity'];
                            final productName = cartData['productName'];
                            final color = cartData['color'];
                            final rom = cartData['rom'];
                            final image = cartData['image'];

                            try {
                              // Add the item to the orders collection
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .add({
                                'orderId': orderId,
                                'userId': _userId,
                                'pid': productId,
                                'productName': productName,
                                'image': image,
                                'price': price,
                                'totalPrice': price * quantity,
                                'quantity': quantity,
                                'color': color,
                                'rom': rom,
                                'orderStatus': 'Processing',
                                'timestamp': Timestamp.now(),
                                // Add timestamp for ordering
                              });

                              // Delete the item from the cart
                              await deleteCartItem(cartItem.id);
                            } catch (error) {
                              print(
                                  'Error adding item to orders collection: $error');
                              // Handle any errors that occur during the process
                            }
                          }

                          // Show a success message or navigate to the next screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Order placed successfully'),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => DeliveryLocationMarkingPage(
                              productData: widget.productData,
                              orderId: orderId),), (route) => false,);
                        },
                        child: Text('Continue'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
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
