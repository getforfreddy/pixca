import 'package:flutter/material.dart';

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

  void confirmOrder(BuildContext context) {
    // Implement logic to confirm the order
    // For example, you can navigate to a success page or show a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Confirmed'),
          content: Text('Your order with ID $orderId has been confirmed successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
