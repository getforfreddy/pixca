import 'package:flutter/material.dart';
class MyAddressSample extends StatefulWidget {
  const MyAddressSample({super.key});

  @override
  State<MyAddressSample> createState() => _MyAddressSampleState();
}

class _MyAddressSampleState extends State<MyAddressSample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Address'),
      ),
      body: Column(
        children: [
          Card(
            child: Text('Address List'),
          ),
        ],
      ),
    );
  }
}