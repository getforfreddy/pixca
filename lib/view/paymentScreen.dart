import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> productData;
  final double totalAmount;

  const PaymentPage({
    Key? key,
    required this.productData,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _showProductDetails = false;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _totalAmount = widget.totalAmount;
  }

  Future<void> placeOrderAndGetTotalAmount(Map<String, dynamic> productData) async {
    double price = double.parse(productData['price'].toString());
    double salesTax = 0.025; // 2.5% sales tax
    double totalAmount = price * (1 + salesTax);

    final orderCollection = FirebaseFirestore.instance.collection('orders');

    // Check if the item already exists in the orders collection
    final querySnapshot = await orderCollection.where('pid', isEqualTo: productData['pid']).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Item already exists in orders collection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have already purchased this item.'),
          duration: Duration(seconds: 2),
        ),
      );
      // Set the _showProductDetails state to false
      setState(() {
        _showProductDetails = false;
      });
    } else {
      // Item doesn't exist, add it to the collection
      await orderCollection.add({...productData, 'totalAmount': totalAmount}).then((value) {
        print('Product added to orders successfully!');
        setState(() {
          _totalAmount = totalAmount;
          _showProductDetails = true;
        });
      }).catchError((error) => print('Error adding product to orders: $error'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Invoice",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                "Pixca",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Model :  ${widget.productData['productName'] ?? ''}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Brand : ${widget.productData['brand'] ?? ''}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Price: Rs ${widget.productData['price'] ?? ''}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Sales Tax: 2.5%',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Total Amount: \$${_totalAmount.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
    );
  }
}
