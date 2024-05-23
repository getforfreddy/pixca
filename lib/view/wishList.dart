import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    try {
      if (userId.isNotEmpty) {
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
      }
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
          favorites.add(productSnapshot.data() as Map<String, dynamic>);
        }
      } catch (error) {
        print('Error fetching product details for $pid: $error');
      }
    }

    setState(() {
      _favoritesList = favorites;
    });
  }

  Future<void> toggleFavoriteStatus(String productId, bool isFavorite) async {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? '';

    try {
      if (isFavorite) {
        // Remove from favorites
        await FirebaseFirestore.instance
            .collection('favorites')
            .doc(userId)
            .collection('userFavorites')
            .doc(productId)
            .delete();
      } else {
        // Add to favorites
        await FirebaseFirestore.instance
            .collection('favorites')
            .doc(userId)
            .collection('userFavorites')
            .doc(productId)
            .set({
          'productId': productId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Update local state to reflect the change
      await fetchFavorites(); // Wait for fetch to complete before setState
    } catch (error) {
      print('Error toggling favorite status: $error');
    }
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
          final productId = productData['productId'];

          bool isFavorite = _favoritesIds.contains(productId);

          return Card(
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
                                  height: 100,
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      toggleFavoriteStatus(productId, isFavorite);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
