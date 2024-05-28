import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:pixca/controller/carousel-Controler.dart';
import 'package:pixca/controller/googleSignInController.dart';
import 'package:pixca/view/addPhonesToFireBase.dart';
import 'package:pixca/view/cameraSample.dart';
import 'package:pixca/view/cartScreen.dart';
import 'package:pixca/view/notificationscreen.dart';
import 'package:pixca/view/phoneScreen.dart';
import 'package:pixca/view/productBrandList.dart';
import 'package:pixca/view/productDetailingPage.dart';
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
  final GetUserDataController _getUserDadtaController = Get.put(GetUserDataController());

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
              child: Text("${userData.isNotEmpty ? userData[0]['username'] : 'N/A'}"),
            ),
            ListTile(
              leading: Icon(CupertinoIcons.cube_box),
              title: Text("Order"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderScreen(),
                  ),
                );
              },
              trailing: Icon(Icons.arrow_forward_ios_sharp),
            ),
            ListTile(
              leading: Icon(CupertinoIcons.heart),
              title: Text("Wishlist"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WishlistScreen(),
                  ),
                );
              },
              trailing: Icon(Icons.arrow_forward_ios_sharp),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsSample(),
                  ),
                );
              },
              trailing: Icon(Icons.arrow_forward_ios_sharp),
            ),
            ListTile(
              leading: Icon(Icons.photo_camera_back),
              title: Text("Upload phone to database"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Addphonestofirebase(),
                  ),
                );
              },
              trailing: Icon(Icons.arrow_forward_ios_sharp),
            ),
            ListTile(
              onTap: () async {
                await googleController.signOutGoogle();
                Navigator.pushReplacementNamed(context, '/login');
              },
              leading: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            )
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
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraSample(),
                ),
              );
            },
            icon: Icon(CupertinoIcons.camera),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active_outlined),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cart),
            label: 'Cart',
          ),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeSample()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationSample()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartSample(productData: {},)),
              );
              break;
          }
        },
      ),
      body: ListView(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhoneSalesSample(),
                    ),
                  );
                },
                child: Text("Phones"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WatchesSample(),
                    ),
                  );
                },
                child: Text("Watches"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccessoriesSample(),
                    ),
                  );
                },
                child: Text("Accessories"),
              ),
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
                  child: Lottie.asset('assect/animations/loadingLottie.json'),
                ),
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
                      child: Image.network(caroselController.carouselImages[index]),
                    ),
                  );
                },
                options: CarouselOptions(height: 300.0, autoPlay: true),
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
                          String selectedBrandName = caroselController.brandNames[index];
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
                  highlightColor: CupertinoColors.activeBlue,
                );
              } else {
                return SizedBox(
                  height: 655,
                  child: FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance.collection('Products').get(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No products found.'));
                      }
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          var productData = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                          String productName = productData['productName'] ?? 'Unnamed Product';
                          String productImage = productData['image'] ?? 'No image found';
                          List<dynamic> colorList = productData['color'] ?? [];
                          String color = colorList.join(', ');
                          String description = productData['description'] ?? 'No description available';
                          String brand = productData['brand'] ?? 'Unknown Brand';
                          double price = 0.0;
                          if (productData['price'] != null) {
                            String priceString = productData['price'].toString();
                            priceString = priceString.replaceAll(RegExp(r'[$,]'), '');
                            price = double.tryParse(priceString) ?? 0.0;
                          }
                          String romString = '';
                          if (productData['ROM'] != null && productData['ROM'] is List<dynamic>) {
                            List<dynamic> rom = productData['ROM'];
                            romString = rom.join(', ');
                          }

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(productData: productData),
                                ),
                              );
                            },
                            child: Card(
                              child: Column(
                                children: [
                                  ClipRect(
                                    child: Image.network(
                                      productImage,
                                      height: 200,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    productName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    brand,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              shape: Border(),
                            ),
                          );
                        },
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
                ),
              ),
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
