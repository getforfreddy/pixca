import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../view/placeOrderAndOrderSummery.dart'; // Adjust path as necessary

class DeliveryLocationMarkingPage extends StatefulWidget {
  final Map<String, dynamic> productData;
  final String orderId;

  const DeliveryLocationMarkingPage({
    Key? key,
    required this.productData,
    required this.orderId,
  }) : super(key: key);

  @override
  _DeliveryLocationMarkingPageState createState() =>
      _DeliveryLocationMarkingPageState();
}

class _DeliveryLocationMarkingPageState
    extends State<DeliveryLocationMarkingPage> {
  late final User user;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController housenoController = TextEditingController();
  TextEditingController roadnameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();

  Position? _position;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    fetchUserAddressData();
    fetchProductNamesFromCart();
  }

  Future<void> fetchUserAddressData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('addresses')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          nameController.text = userData['name'] ?? '';
          phoneController.text = userData['phone'] ?? '';
          housenoController.text = userData['houseNo'] ?? '';
          roadnameController.text = userData['roadName'] ?? '';
          cityController.text = userData['city'] ?? '';
          stateController.text = userData['state'] ?? '';
          pinCodeController.text = userData['pincode'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user address data: $e');
    }
  }

  Future<void> fetchProductNamesFromCart() async {
    try {
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (cartSnapshot.docs.isNotEmpty) {
        List<String> productNames = [];
        cartSnapshot.docs.forEach((doc) {
          productNames.add(doc['productName']);
        });
        setState(() {
          widget.productData['productNames'] = productNames;
        });
      }
    } catch (e) {
      print('Error fetching product names from cart: $e');
    }
  }

  Future<void> getCurrentLocation() async {
    bool isLocationEnabled = await checkPermissionPhone();
    if (!isLocationEnabled) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _position = position;
        _getAddressFromLatLng(_position!);
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          housenoController.text = place.name ?? '';
          roadnameController.text = place.street ?? '';
          cityController.text = place.subLocality ?? '';
          stateController.text = place.administrativeArea ?? '';
          pinCodeController.text = place.postalCode ?? '';
        });
      }
    } catch (e) {
      print('Error getting address from coordinates: $e');
    }
  }

  Future<bool> checkPermissionPhone() async {
    bool isLocationEnabled;
    LocationPermission permission;
    isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Location is disabled, please enable your location")));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Location is disabled")));

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Location permissions are permanently denied")));

      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add delivery address"),
      ),
      body: ListView(
        children: [
          Form(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    (widget.productData['productNames'] as List<String>).join(', '),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: housenoController,
                    decoration: InputDecoration(
                        labelText: "House number",
                        border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: roadnameController,
                    decoration: InputDecoration(
                        labelText: "LandMark", border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(
                        labelText: "Road name or area",
                        border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: stateController,
                    decoration: InputDecoration(
                        labelText: "State", border: OutlineInputBorder()),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: 150,
                        child: TextFormField(
                          controller: pinCodeController,
                          decoration: InputDecoration(
                              labelText: "Pincode",
                              border: OutlineInputBorder()),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: ElevatedButton(
                          onPressed: () {
                            getCurrentLocation();
                          },
                          child: Text("Use my location")),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                saveAddress();
              },
              child: Text('Save Address'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveAddress() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    Map<String, dynamic> addressData = {
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'name': nameController.text,
      'phone': phoneController.text,
      'houseNo': housenoController.text.isNotEmpty ? housenoController.text : null,
      'roadName': roadnameController.text.isNotEmpty ? roadnameController.text : null,
      'city': cityController.text.isNotEmpty ? cityController.text : null,
      'state': stateController.text.isNotEmpty ? stateController.text : null,
      'pincode': pinCodeController.text.isNotEmpty ? pinCodeController.text : null,
    };

    try {
      // Logging the orderId for debugging purposes
      print('Order ID: ${widget.orderId}');

      DocumentSnapshot orderSnapshot = await firestore.collection('orders').doc(widget.orderId).get();
      if (!orderSnapshot.exists) {
        print('Order document not found for orderId: ${widget.orderId}');
        throw Exception('Order document not found');
      }

      DocumentReference addressRef = await firestore.collection('addresses').add(addressData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address saved successfully')),
      );

      await firestore.collection('orders').doc(widget.orderId).update({
        'address': addressRef,
        'orderStatus': 'Processing',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaceOrderAndOrderSummery(
            orderId: widget.orderId,
            addressData: addressData,
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save address'),
          duration: Duration(seconds: 3),
        ),
      );
      print('Error saving address: $error');
    }
  }
}
