import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SummeryAddressAndAmount extends StatefulWidget {
  final String? orderId; // Add orderId as a parameter

  const SummeryAddressAndAmount({Key? key, this.orderId}) : super(key: key);

  @override
  State<SummeryAddressAndAmount> createState() =>
      _SummeryAddressAndAmountState();
}

class _SummeryAddressAndAmountState extends State<SummeryAddressAndAmount> {
  String address = '';
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    fetchAddressAndTotalAmount();
  }

  Future<void> fetchAddressAndTotalAmount() async {
    try {
      // Fetch address from Firestore
      DocumentSnapshot addressSnapshot = await FirebaseFirestore.instance
          .collection('addresses')
          .doc('addressDocumentId') // Replace with the actual document ID
          .get();
      Map<String, dynamic>? addressData =
          addressSnapshot.data() as Map<String, dynamic>?;
      if (addressData != null) {
        setState(() {
          address =
              '${addressData['houseNo'] ?? ''}, ${addressData['roadName'] ?? ''}, ${addressData['city'] ?? ''}, ${addressData['state'] ?? ''} - ${addressData['pincode'] ?? ''}';
        });
      } else {
        setState(() {
          address = 'No address found';
        });
      }

      // Fetch total amount from cart
      QuerySnapshot cartSnapshot =
          await FirebaseFirestore.instance.collection('cart').get();
      double total = 0;
      cartSnapshot.docs.forEach((doc) {
        total += (doc['price'] ?? 0) * (doc['quantity'] ?? 0);
      });
      setState(() {
        totalAmount = total;
      });
    } catch (error) {
      print('Error fetching address and total amount: $error');
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
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
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
                                Text(
                                  productName,
                                  style: TextStyle(fontSize: 25),
                                ),
                                Text('ROM: $color',
                                    style: TextStyle(fontSize: 15)),
                                Text('ROM: $rom',
                                    style: TextStyle(fontSize: 15)),
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
                    '\$$totalAmount',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => PaymentPage(
              //         userId: FirebaseAuth.instance.currentUser!.uid,
              //         orderId: widget.orderId!,
              //         totalAmount: totalAmount,
              //         brand: brand,
              //         image1: image1,)
              //       //PaymentPage(amount: totalAmount),
              //       ),
              // );
            },
            child: Text('Proceed to Payment'),
          ),
        ],
      ),
    );
  }
}
