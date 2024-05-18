import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpandSupportSample extends StatefulWidget {
  const HelpandSupportSample({super.key});

  @override
  State<HelpandSupportSample> createState() => _HelpandSupportSampleState();
}

class _HelpandSupportSampleState extends State<HelpandSupportSample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help and Support"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: Icon(CupertinoIcons.search),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: Icon(CupertinoIcons.cart),
          )
        ],
      ),
      body: Column(
        children: [
          Card(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      Text('Get quick customer support by selecting your item'),
                ),
                Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/pixca-d82c7.appspot.com/o/icons%20and%20imojes%2Fcustomer-service.png?alt=media&token=ad7ef88f-51c2-41bd-8e77-e04482acdfcc',
                  height: 100,
                  width: 100,
                ),
              ],
            ),
          ),
          Text('Selecte the order to track and manage it conveniently'),
        ],
      ),
    );
  }
}
