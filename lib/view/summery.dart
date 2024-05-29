import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pixca/view/paymentScreen.dart';

class SummeryAddressAndAmount extends StatefulWidget {
  final String? orderId; // Add orderId as a parameter

  const SummeryAddressAndAmount({Key? key, this.orderId}) : super(key: key);

  @override
  State<SummeryAddressAndAmount> createState() =>
      _SummeryAddressAndAmountState();
}

class _SummeryAddressAndAmountState extends State<SummeryAddressAndAmount> {
  String address = 'Loading...';
  double totalAmount = 0;
  bool isLoading = true; // Track loading state

  // Controllers for address fields
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final TextEditingController housenoController = TextEditingController();
  final TextEditingController roadnameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

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
          address = addressData.toString();
          isLoading = false; // Data fetched, set loading to false
        });
      } else {
        setState(() {
          address = 'No data found for order';
          isLoading = false; // No address data found, set loading to false
        });
      }

      // Fetch total amount from user's cart
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: 'userUid') // Replace with the user's UID
          .get();
      double total = 0;
      if (cartSnapshot.docs.isNotEmpty) {
        cartSnapshot.docs.forEach((doc) {
          total += doc['totalPrice'];
        });
        setState(() {
          totalAmount = total;
        });
      } else {
        setState(() {
          totalAmount = 0;
          if (!isLoading) {
            address = 'No data found for order';
          }
        });
      }
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
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
              saveAddress();
            },
            child: Text('Proceed to Payment'),
          ),
        ],
      ),
    );
  }

  Future<void> saveAddress() async {
    if (widget.orderId != null) {
      // Save address to Firestore
      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
        'address': {
          'name': nameController.text,
          'phone': phoneController.text,
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'houseNo': housenoController.text.isNotEmpty
              ? housenoController.text
              : null,
          'roadName': roadnameController.text.isNotEmpty
              ? roadnameController.text
              : null,
          'city': cityController.text.isNotEmpty ? cityController.text : null,
          'state': stateController.text.isNotEmpty ? stateController.text : null,
          'pincode': pinCodeController.text.isNotEmpty
              ? pinCodeController.text
              : null,
        }
      });

      // Fetch the total amount and other required fields from the orders collection
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).get();
      if (orderSnapshot.exists) {
        double totalAmount = orderSnapshot['totalAmount'];
        String brand = orderSnapshot['brand'];
        String image1 = orderSnapshot['image1'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Address saved successfully')),
        );

        // Navigate to the payment page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PaymentPage(
            userId: FirebaseAuth.instance.currentUser!.uid,
            orderId: widget.orderId!,
            totalAmount: totalAmount,
            brand: brand,
            image1: image1,
          )),
        );
      }
    }
  }
}
