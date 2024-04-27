import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pixca/view/phoneScreen.dart';
import 'package:pixca/view/watchesScreenSample.dart';

class AccessoriesSample extends StatefulWidget {
  const AccessoriesSample({super.key});

  @override
  State<AccessoriesSample> createState() => _AccessoriesSampleState();
}

class _AccessoriesSampleState extends State<AccessoriesSample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Accessories",
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: ListView(
        children: [
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhoneSalesSample(),
                          ));
                    });
                  },
                  child: Text("Phone")),
              TextButton(
                  onPressed: () {
                    setState(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WatchesSample(),
                          ));
                    });
                  },
                  child: Text("Watches")),
              // TextButton(onPressed: () {}, child: Text("Accessories")),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Sliding Containers",
              style: TextStyle(fontSize: 30),
            ),
          ), 
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              height: 150.h,
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200,
                    margin: EdgeInsets.all(2),
                    color: Colors.green[50],
                    child: Text("image$index"),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Grid View",
              style: TextStyle(fontSize: 30),
            ),
          ),
          SizedBox(
            height: 505,
            // Fixed height for the GridView
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns in the grid
              ),
              itemCount: 4, // Number of items in the grid
              itemBuilder: (context, index) {
                return Container(
                  width: 400,
                  margin: EdgeInsets.all(8),
                  color: Colors.blue[100],
                  child: Center(
                    child: Text('Grid Item $index',
                        style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Sliding Containers",
              style: TextStyle(fontSize: 30),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              height: 150.h,
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200,
                    margin: EdgeInsets.all(2),
                    color: Colors.green[100],
                    child: Text("image$index"),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Tail",
              style: TextStyle(fontSize: 30),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 400,
              height: 200,
              color: Colors.grey[300],
              child: Center(
                  child: Text(
                "End",
                style: TextStyle(
                  fontSize: 20,
                ),
              )),
            ),
          )
        ],
      ),
    );
  }
}
