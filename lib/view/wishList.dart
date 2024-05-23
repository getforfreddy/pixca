import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixca/controller/carousel-Controler.dart';

class WishList extends StatefulWidget {
  const WishList({super.key});

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  ImageController wishLists = Get.put(ImageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wishlist"),
      ),
      body: Center(
        child: Text("No wishlist"),
      ),
    );
  }
}
