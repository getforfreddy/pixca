import 'package:flutter/material.dart';
class PlaceOrderAndOrderSummery extends StatefulWidget {
  const PlaceOrderAndOrderSummery({super.key});

  @override
  State<PlaceOrderAndOrderSummery> createState() => _PlaceOrderAndOrderSummeryState();
}

class _PlaceOrderAndOrderSummeryState extends State<PlaceOrderAndOrderSummery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OrderSummery',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
      ),
      body: Column(
        children: [


          ElevatedButton(onPressed: () {
            setState(() {
              
            });
          }, child: Text('Confirm Order'))

        ],
      ),
    );
  }
}
