import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageController extends GetxController {
  // Creating RxList to get the images from firebase
  RxList<String> carouselImages = RxList<String>([]);
  RxList<String> brandImages = RxList<String>([]);
  RxList<String> newLaunchedGrid = RxList<String>([]);
  RxList<String> gridPhoneName = RxList<String>([]);
  RxList<String> brandNames = RxList<String>([]);
  @override
  void onInit() {
    super.onInit();
    fetchCaroselImages();
    fetchBrandImages();
    fetchNewLaunchedGrids();
    fetchGridPhoneName();
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
        update(); // Update RxList after modification
      }
    } catch (e) {}
  }

  //
  fetchBrandImages() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('brand-Images').get();
      if (snapshot.docs.isNotEmpty) {
        List<String> images = [];
        List<String> names = []; // Renamed the brand names list to avoid conflict
        snapshot.docs.forEach((doc) {
          String imageUrl = doc['images'] as String;
          String brandName = doc['brand'] as String;
          images.add(imageUrl);
          names.add(brandName);
        });
        brandImages.value = images;
        brandNames.value = names; // Assign the names to the brandNames RxList
      }
    } catch (e) {
      print('Error fetching brand images: $e'); // Log the error for debugging
    }
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

  fetchGridPhoneName() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("GridViewNewLaunched5g")
          .get();
      if (snapshot.docs.isNotEmpty) {
        gridPhoneName.value =
            snapshot.docs.map((e) => e['phoneName'] as String).toList();
      }
    } catch (e) {}
  }

  fetchWishList()async{



  }
}