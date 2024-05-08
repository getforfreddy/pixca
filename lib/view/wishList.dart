import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pixca/controller/carousel-Controler.dart';
import 'package:shimmer/shimmer.dart';
class WishList extends StatefulWidget {
  const WishList({super.key});

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  ImageController wishLists= Get.put(ImageController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wishlist"),
      ),
      body: Column(
        children: [

          // Obx(() {
          //   if(wishLists.wishListS.isEmpty){
          //     return Shimmer(child: Card(), gradient: )
          //   }
          // })




          // Obx(() {
          //   if (wishLists.wishListS.isEmpty) {
          //     return Shimmer.fromColors(
          //       child: CircularProgressIndicator(),
          //       baseColor: Colors.grey,
          //       highlightColor: Colors.black38,
          //     );
          //   } else {
          //     return Padding(
          //       padding: const EdgeInsets.only(top: 20),
          //       child: Container(
          //         height: 320.h,
          //         color: Colors.white,
          //         child: ListView.builder(
          //           // scrollDirection: Axis.horizontal,
          //           itemCount: wishLists.wishListS.length,
          //           itemBuilder: (context, index) {
          //             return InkWell(
          //               onTap: () {
          //                 print("BrandImage");
          //               },
          //               child: Column(
          //                 children: [
          //                   Card(
          //                     child: Image.network(wishLists.wishListS[index]),
          //                   ),
          //                 ],
          //               ),
          //             );
          //           },
          //         ),
          //       ),
          //     );
          //   }
          // }),

        ],
      ),
    );
  }
}
