import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CartSample extends StatefulWidget {
  const CartSample({super.key});

  @override
  State<CartSample> createState() => _CartSampleState();
}

class _CartSampleState extends State<CartSample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/pixca-d82c7.appspot.com/o/icons%20and%20imojes%2Fdata-security%20(1).png?alt=media&token=c4cbce7c-e390-4010-b21c-6e1bfbdc6b80',
                  height: 100,
                  width: 100,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Product'),
                ),

              ],
            ),
          ),
          Card(child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Price'),
                Text('QTY'),
                Text('Total')
              ],
            ),
          ),
        ],
      ),
    );
  }
}
