import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pixca/view/paymentScreen.dart';

class SummeryAddressAndAmount extends StatefulWidget {
  final String? orderId; // Add orderId as a parameter

  const SummeryAddressAndAmount({Key? key, this.orderId}) : super(key: key);

  @override
  State<SummeryAddressAndAmount> createState() =>
      _SummeryAddressAndAmountState();
}

class _SummeryAddressAndAmountState extends State<SummeryAddressAndAmount> {
  String address = '';
  String userName = '';
  String userPhone = '';
  double totalAmount = 0.0;
  int grandTotal = 0;

  @override
  void initState() {
    super.initState();
    fetchAddressAndTotalAmount();
    fetchGrandTotal();
  }

  Future<void> fetchAddressAndTotalAmount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is currently signed in.');
      return;
    }

    try {
      // Fetch addresses from Firestore
      QuerySnapshot addressSnapshot = await FirebaseFirestore.instance
          .collection('addressbook')
          .where('userId', isEqualTo: user.uid)
          .get();

      List<String> addresses = [];
      String? name;
      String? phone;

      addressSnapshot.docs.forEach((doc) {
        Map<String, dynamic>? addressData = doc.data() as Map<String, dynamic>?;
        if (addressData != null) {
          if (name == null && phone == null) {
            name = addressData['name'];
            phone = addressData['phone'];
          }
          addresses.add(
            '${addressData['houseNo'] ?? ''}, ${addressData['roadName'] ?? ''}, ${addressData['city'] ?? ''}, ${addressData['state'] ?? ''} - ${addressData['pincode'] ?? ''}',
          );
        }
      });

      setState(() {
        address = addresses.isNotEmpty ? addresses.join('\n') : 'No address found';
        userName = name ?? 'No name found';
        userPhone = phone ?? 'No phone number found';
      });

      // // Fetch total amount from orders
      // QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
      //     .collection('orders')
      //     .where('userId', isEqualTo: user.uid)
      //     .get();
      //
      // double total = 0;
      // orderSnapshot.docs.forEach((doc) {
      //   total += (doc['price'] ?? 0) * (doc['quantity'] ?? 0);
      // });
      //
      // setState(() {
      //   totalAmount = total;
      // });
    } catch (error) {
      print('Error fetching address and total amount: $error');
    }
  }
  Future<void> fetchGrandTotal() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .get();

        int total = 0;

        for (var orderDoc in orderSnapshot.docs) {
          // Log the document data to debug
          print('Document data: ${orderDoc.data()}');

          // Get the price string and remove non-numeric characters
          String priceStr = orderDoc['price'] ?? '0';
          priceStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');

          // Convert the cleaned price string to an integer
          int price = int.tryParse(priceStr) ?? 0;

          // Log the converted price
          print('Converted price: $price');

          total += price;
        }

        // Log the total amount
        print('Total amount: $total');

        setState(() {
          grandTotal = total;
        });
      } catch (e) {
        // Handle potential errors
        print('Error fetching orders: $e');
        Fluttertoast.showToast(
            msg: 'Error fetching orders',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Summary'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    userName,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Phone',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    userPhone,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    address,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders')
                .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('Your cart is empty'));
              } else {
                final ordersdata = snapshot.data!.docs;
                return Expanded(
                  child: ListView.builder(
                    itemCount: ordersdata.length,
                    itemBuilder: (context, index) {
                      final orderData = ordersdata[index];
                      final orders = orderData.data() as Map<String, dynamic>;
                      final productName = orders['productName'];
                      final color = orders['color'];
                      final quantity= orders['quantity'];
                      // Handling the color field
                      dynamic ordersData = orders['color'];
                      List<String> colorList = [];
                      if (ordersData is String) {
                        // If colorData is a string, split it by comma to create a list
                        colorList = ordersData.split(',');
                      } else if (ordersData is List) {
                        // If colorData is already a list, assign it directly
                        colorList = List<String>.from(ordersData);
                      }
                      final image = orders['image'];
                      final rom = orders['rom'];

                      return GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Card(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    Text('color: $color',
                                        style: TextStyle(fontSize: 15)),
                                    Text('quantity: $quantity',
                                        style: TextStyle(fontSize: 15)),
                                    Text('ROM: $rom',
                                        style: TextStyle(fontSize: 15)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$$grandTotal',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RazorPayPage()
                    //PaymentPage(amount: totalAmount),
                    ),
              );
            },
            child: Text('Proceed to Payment'),
          ),
        ],
      ),
    );
  }
}
