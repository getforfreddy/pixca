import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:pixca/controller/carousel-Controler.dart';
import 'package:pixca/view/phoneScreen.dart';
import 'package:pixca/view/settingsScreen.dart';
import 'package:pixca/view/watchesScreenSample.dart';
import 'package:pixca/view/wishList.dart';
import 'package:shimmer/shimmer.dart';

import 'accessoriesScreen.dart';
import 'login.dart';
import 'orderScreen.dart';

class HomeSample extends StatefulWidget {
  const HomeSample({super.key});

  @override
  State<HomeSample> createState() => _HomeSampleState();
}

class _HomeSampleState extends State<HomeSample> {
  ImageController caroselController = Get.put(ImageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 90),
              child: CircleAvatar(
                radius: 70.r,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "userName",
                style: TextStyle(fontSize: 30),
              ),
            ),
            ListTile(
              leading: Icon(CupertinoIcons.cube_box),
              title: Text("Order"),
              onTap: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderScreen(),
                      ));
                });
              },
              trailing: Icon(Icons.arrow_forward_ios_sharp),
            ),
            ListTile(
              leading: Icon(CupertinoIcons.heart),
              title: Text("Wishlist"),
              onTap: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WishList(),
                      ));
                });
              },
              trailing: Icon(Icons.arrow_forward_ios_sharp),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsSample(),
                      ));
                });
              },
              trailing: Icon(Icons.arrow_forward_ios_sharp),
            ),
            ListTile(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginSample(),
                      ),
                          (route) => false);
                },
                leading: Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ))
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          "Pixca",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.r),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: Icon(CupertinoIcons.search),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active_outlined),
              label: "Notification"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.cart), label: "Cart"),
        ],
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
                  child: Text("Phones")),
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
              TextButton(
                  onPressed: () {
                    setState(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccessoriesSample(),
                          ));
                    });
                  },
                  child: Text("Accessories")),
            ],
          ),

          // Obx(() {
          //   if (caroselController.carouselImages.isEmpty) {
          //     return Shimmer.fromColors(
          //       child: Text("Loading"),
          //       baseColor: Colors.grey,
          //       highlightColor: CupertinoColors.activeBlue,
          //     );
          //   } else {
          //     return CarouselSlider.builder(
          //       itemCount: caroselController.carouselImages.length,
          //       itemBuilder: (context, index, realIndex) {
          //         return InkWell(
          //           onTap: () {
          //             print("Hello");
          //           },
          //           child: Padding(
          //             padding: EdgeInsets.all(10),
          //             child: Image.network(caroselController.carouselImages[index]),
          //           ),
          //         );
          //       },
          //       options: CarouselOptions(height: 500.0, autoPlay: true),
          //     );
          //   }
          // }),
          Obx(() {
            if (caroselController.carouselImages.isEmpty) {
              return Center(heightFactor: 500.h,
                widthFactor: 500.w,
                child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Lottie.asset('assect/animations/loadingLottie.json')),
              );
            } else {
              return CarouselSlider.builder(
                itemCount: caroselController.carouselImages.length,
                itemBuilder: (context, index, realIndex) {
                  return InkWell(
                    onTap: () {
                      print("Hello");
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Image.network(
                          caroselController.carouselImages[index]),
                    ),
                  );
                },
                options: CarouselOptions(height: 500.0, autoPlay: true),
              );
            }
          }),
          Obx(() {
            if (caroselController.brandImages.isEmpty) {
              return Shimmer.fromColors(
                child: CircularProgressIndicator(),
                baseColor: Colors.grey,
                highlightColor: Colors.black38,
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  height: 150.h,
                  color: Colors.white,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: caroselController.brandImages.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          print("BrandImage");
                        },
                        child: Container(
                          width: 200,
                          margin: EdgeInsets.all(2),
                          color: Colors.white60,
                          child: Image.network(caroselController.brandImages[index]),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          }),


          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Grid View",
              style: TextStyle(fontSize: 30),
            ),
          ),

          Obx(
                () {
              if (caroselController.newLaunchedGrid.isEmpty) {
                return Shimmer.fromColors(child: Text("Loading"),
                    baseColor: Colors.grey,
                    highlightColor: CupertinoColors.activeBlue);
              } else {
                return SizedBox(
                  height: 505,
                  // Fixed height for the GridView
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns in the grid
                    ),
                    itemCount: 4, // Number of items in the grid
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          print("GridView");
                        },
                        child: Container(
                          width: 400,
                          margin: EdgeInsets.all(8),
                          color: Colors.blue[50],
                          child: Image.network(
                              caroselController.newLaunchedGrid[index]),
                        ),
                      );
                    },
                  ),
                );
              }
            },
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
