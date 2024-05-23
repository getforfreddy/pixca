import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixca/view/productBrandList.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart';
import '../controller/carousel-Controler.dart';


class Testersample extends StatefulWidget {
  const Testersample({super.key});

  @override
  State<Testersample> createState() => _TestersampleState();
}

class _TestersampleState extends State<Testersample> {

  ImageController carouselController = Get.put(ImageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Column(
        children: [
          Obx(
                () {
              if (carouselController.newLaunchedGrid.isEmpty) {
                return Shimmer.fromColors(
                    child: Text("Loading"),
                    baseColor: Colors.grey,
                    highlightColor: CupertinoColors.activeBlue);
              } else {
                return SizedBox(
                  height: 505,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          String selectedBrandName = carouselController
                              .brandNames[index]; // Accessing brandNames RxList
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductListPage(brand: selectedBrandName),
                            ),
                          );
                        },
                        child: Card(
                          child: Column(
                            children: [
                              ClipRect(
                                child: Image.network(
                                  carouselController.newLaunchedGrid[index],
                                  height: 200,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                carouselController.gridPhoneName[index],
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
        ],
      ),
    );
  }
}
