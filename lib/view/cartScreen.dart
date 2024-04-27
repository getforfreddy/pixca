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
          Text("Cart",style: TextStyle(fontSize: 90.r),)
        ],
      ),
    );
  }
}
