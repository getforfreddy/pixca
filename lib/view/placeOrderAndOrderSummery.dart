import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixca/view/paymentScreen.dart';

class PlaceOrderAndOrderSummery extends StatelessWidget {
  final Map<String, dynamic> addressData;
  final String? orderId; // Define orderId as a parameter

  const PlaceOrderAndOrderSummery({
    Key? key,
    required this.addressData,
    this.orderId, // Accept orderId in the constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Summary',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              'Address: ${addressData['houseNo'] ?? ''}, ${addressData['roadName'] ?? ''}, ${addressData['city'] ?? ''}, ${addressData['state'] ?? ''} - ${addressData['pincode'] ?? ''}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                confirmOrder(context);
              },
              child: Text('Confirm Order'),
            ),
          ],
        ),
      ),
    );
  }

  void confirmOrder(BuildContext context) async {
    // Fetch order details
    try {
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();

      if (!orderSnapshot.exists) {
        print('Order document not found for orderId: $orderId');
        return;
      }

      // Get order data
      Map<String, dynamic> orderData = orderSnapshot.data() as Map<String, dynamic>;

      // Navigate to PaymentPage with order details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            orderId: orderId!, // Assert that orderId is not null
            image1: orderData['image1'], // Pass the relevant order details
            brand: orderData['brand'],
            totalAmount: orderData['totalAmount'],
            userId: orderData['userId'],
          ),
        ),
      );


    } catch (e) {
      print('Error fetching order details: $e');
    }
  }
}
