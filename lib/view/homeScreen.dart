import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:pixca/controller/carousel-Controler.dart';
import 'package:pixca/controller/googleSignInController.dart';
import 'package:pixca/view/phoneScreen.dart';
import 'package:pixca/view/productBrandList.dart';
import 'package:pixca/view/settingsScreen.dart';
import 'package:pixca/view/upload_file.dart';
import 'package:pixca/view/watchesScreenSample.dart';
import 'package:pixca/view/wishList.dart';
import 'package:shimmer/shimmer.dart';

import '../controller/getUserDataController.dart';
import 'accessoriesScreen.dart';
import 'orderScreen.dart';

class HomeSample extends StatefulWidget {
  const HomeSample({super.key});

  @override
  State<HomeSample> createState() => _HomeSampleState();
}

class _HomeSampleState extends State<HomeSample> {
  ImageController caroselController = Get.put(ImageController());
  GoogleController googleController = Get.put(GoogleController());
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GetUserDataController _getUserDadtaController =
      Get.put(GetUserDataController());

  // PhoneNameController gridPhoneNameController=Get.put(GoogleController());

  late final User user;
  late List<QueryDocumentSnapshot<Object?>> userData = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _getUserData();
  }

  Future<void> _getUserData() async {
    userData = await _getUserDadtaController.getUserData(user.uid);
    if (mounted) {
      setState(() {});
    }
  }

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
                backgroundImage: NetworkImage(
                  userData.isNotEmpty &&
                          userData[0]['userImg'] != null &&
                          userData[0]['userImg'].isNotEmpty
                      ? userData[0]['userImg']
                      : 'https://via.placeholder.com/120',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "${userData.isNotEmpty ? userData[0]['username'] : 'N/A'}"),
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
              leading: Icon(Icons.photo_camera_back),
              title: Text("Upload image"),
              onTap: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UploadImageFile(),
                      ));
                });
              },
              trailing: Icon(Icons.arrow_forward_ios_sharp),
            ),
            ListTile(
                onTap: () async {
                  await googleController.signOutGoogle();
                  print(
                      "*************** Logged out **************************************");
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
          Obx(() {
            if (caroselController.carouselImages.isEmpty) {
              return Center(
                heightFactor: 500.h,
                widthFactor: 500.w,
                child: SizedBox(
                    width: 100,
                    height: 100,
                    child:
                        Lottie.asset('assect/animations/loadingLottie.json')),
              );
            } else {
              return CarouselSlider.builder(
                itemCount: caroselController.carouselImages.length,
                itemBuilder: (context, index, realIndex) {
                  final uid = caroselController.carouselImages[index];

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(uid: uid),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Image.network(
                          caroselController.carouselImages[index]),
                    ),
                  );
                },
                options: CarouselOptions(height:300.0, autoPlay: true),
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
                  height: 110.h,
                  color: Colors.white,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: caroselController.brandImages.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          String selectedBrandName = caroselController.brandNames[index]; // Accessing brandNames RxList
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductListPage(brand: selectedBrandName),
                            ),
                          );
                        },

                        child: ClipOval(
                          child: CircleAvatar(
                            radius: 100,
                            backgroundImage: NetworkImage(
                              caroselController.brandImages[index],
                            ),
                            backgroundColor: Colors.transparent,
                          ),
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
                return Shimmer.fromColors(
                    child: Text("Loading"),
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
                        child: Card(
                          child: Column(
                            children: [
                              ClipRect(
                                child: Image.network(
                                  caroselController.newLaunchedGrid[index],
                                  height: 200,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                caroselController.gridPhoneName[index],
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          shape: Border(),
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

class DetailsPage extends StatelessWidget {
  final String uid;

  const DetailsPage({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: Center(
        child: Text('UID: $uid'),
      ),
    );
  }
}
