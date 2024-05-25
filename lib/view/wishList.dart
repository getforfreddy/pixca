import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pixca/view/productDetailingPage.dart';

class WishlistScreen extends StatefulWidget {
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<String> _favoritesIds = [];
  List<Map<String, dynamic>> _favoritesList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? '';

    if (userId.isEmpty) {
      print('User ID is empty.');
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .collection('userFavorites')
          .get();

      List<String> ids = querySnapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        _favoritesIds = ids;
      });

      // Fetch details for each favorite product
      await getFavoritesDetails();
    } catch (error) {
      print('Error fetching favorites: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getFavoritesDetails() async {
    List<Map<String, dynamic>> favorites = [];

    for (String pid in _favoritesIds) {
      try {
        DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
            .collection('Products')
            .doc(pid)
            .get();

        if (productSnapshot.exists) {
          Map<String, dynamic>? data = productSnapshot.data() as Map<String, dynamic>?;
          if (data != null) {
            data['productId'] = pid; // Ensure productId is included
            favorites.add(data);
          } else {
            print('Product data is null for product ID: $pid');
          }
        } else {
          print('Product does not exist for product ID: $pid');
        }
      } catch (error) {
        print('Error fetching product details for $pid: $error');
      }
    }

    setState(() {
      _favoritesList = favorites;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _favoritesList.isEmpty
          ? Center(child: Text('No items in wishlist.'))
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _favoritesList.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> productData = _favoritesList[index];
          String productName =
              productData['productName'] ?? 'Product Name Not Available';
          String price = productData['price'] != null
              ? 'Rs ${productData['price']}'
              : 'Price Not Available';
          final imageUrl = productData['image'] ?? '';
          final productId = productData['productId'] ?? '';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(productData: productData),
                ),
              );
            },
            child: Card(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imageUrl.isNotEmpty)
                                Center(
                                  child: Image.network(
                                    imageUrl,
                                    height: 150,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              SizedBox(height: 8.0),
                              Text(
                                productName,
                                style: TextStyle(fontSize: 15.sp),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                price,
                                style: TextStyle(fontSize: 15.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}