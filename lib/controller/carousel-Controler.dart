import 'dart:ffi';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageController extends GetxController {
  // Creating RxList to get the images from firebase
  RxList<String> carouselImages = RxList<String>([]);
  RxList<String> brandImages = RxList<String>([]);
  RxList<String> newLaunchedGrid = RxList<String>([]);

  @override
  void onInit() {
    super.onInit();
    fetchCaroselImages();
    fetchBrandImages();
    fetchNewLaunchedGrids();
  }

  //
  fetchCaroselImages() async {
    try {
      //   Connecting to collection
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('CaresaulSlider').get();
      // Check the collection is not empty,atleast one doc
      if (snapshot.docs.isNotEmpty) {
        carouselImages.value =
            snapshot.docs.map((doc) => doc['Image'] as String).toList();
      }
    } catch (e) {}
  }

  //
  fetchBrandImages() async {
    try {
      //   Connecting to collection
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('brand-Images').get();
      // Check the collection is not empty,atleast one doc
      if (snapshot.docs.isNotEmpty) {
        brandImages.value =
            snapshot.docs.map((doc) => doc['images'] as String).toList();
      }
    } catch (e) {}
  }

  fetchNewLaunchedGrids() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('GridViewNewLaunched5g')
          .get();
      if (snapshot.docs.isNotEmpty) {
        newLaunchedGrid.value =
            snapshot.docs.map((doc) => doc['GridImage'] as String).toList();
      }
    } catch (e) {}
  }
}
