import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Stream<QuerySnapshot> _orderStream;

  @override
  void initState() {
    super.initState();
    _orderStream = _getOrdersStream();
  }

  Stream<QuerySnapshot> _getOrdersStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('orderStatus', isEqualTo: 'Success')
          .snapshots();
    } else {
      return Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No orders found.'),
            );
          } else {
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                // You can build your order item widget here
                // Example:
                return ListTile(
                  title: Text(doc['productName']),
                  subtitle: Text('Price: ${doc['totalPrice']}'),
                  // Add more details as needed
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
