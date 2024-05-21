import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pixca/view/placeOrderAndOrderSummery.dart';

import '../controller/getUserDataController.dart';
import '../controller/googleSignInController.dart';

class DeliveryLocationMarkingPage extends StatefulWidget {
  const DeliveryLocationMarkingPage({super.key});

  @override
  State<DeliveryLocationMarkingPage> createState() =>
      _DeliveryLocationMarkingPageState();
}

class _DeliveryLocationMarkingPageState
    extends State<DeliveryLocationMarkingPage> {
  final GoogleController googleController = GoogleController();
  final GetUserDataController _getUserDadtaController =
      Get.put(GetUserDataController());
  String? address, pincode, state, houseno, city, roadname, customerName;
  Position? _position;

  late final User user;
  List<QueryDocumentSnapshot<Object?>> userData = [];
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    phoneController = TextEditingController();
    _getUserData();
  }

  Future<void> _getUserData() async {
    userData = await _getUserDadtaController.getUserData(user.uid);
    if (userData.isNotEmpty) {
      phoneController.text = userData[0]['phone'] ?? '';
    }
    if (mounted) {
      setState(() {});
    }
  }

  TextEditingController pinCodeController = TextEditingController();
  TextEditingController housenoController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController roadnameController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  Future<bool> checkPermissionPhone() async {
    bool isLocationEnabled;
    LocationPermission permission;
    isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Loction is disabled, please enable your loction")));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Loction is disabled")));

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Loction permission are permintly denied")));

      return false;
    }
    return true;
  }

  Future<void> getCurrentLocation() async {
    final HasPermission = await checkPermissionPhone();
    if (!HasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _position = position;
        _getAddressFromLatLng(_position!);
      });
    }).catchError((e) {});
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(_position!.latitude, _position!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        address = '${place.street}, ${place.subLocality},'
            ' ${place.postalCode}, '
            '${place.administrativeArea},${place.name}';
        pincode = place.postalCode;
        houseno = place.name;
        roadname = place.street;
        city = place.subLocality;
        state = place.administrativeArea;
        housenoController.text = houseno.toString();
        roadnameController.text = roadname.toString();
        cityController.text = city.toString();
        stateController.text = state.toString();
        pinCodeController.text = pincode.toString();
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add delivery address"),
      ),
      body: ListView(
        children: [
          // Text(
          //   "${address ?? ''}",
          //   style: TextStyle(fontSize: 20),
          // ),

          Form(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                      label: Text("Full Name"), border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                      label: Text("Phone Number"),
                      border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: housenoController,
                  decoration: InputDecoration(
                      label: Text("House number"),
                      border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: roadnameController,
                  decoration: InputDecoration(
                      label: Text("LandMark"), border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(
                      label: Text("Road name or area"),
                      border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: stateController,
                  decoration: InputDecoration(
                      label: Text("State"), border: OutlineInputBorder()),
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
                            label: Text("Pincode"),
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
          )),
          Padding(
            padding: const EdgeInsets.only(right: 155, left: 155),
            child: ElevatedButton(
              onPressed: () {
                // Call function to save address
                saveAddress();
              },
              child: Text('Save Address'),
            ),
          ),
        ],
      ),
    );
  }

// Function to save the address in Firestore
  Future<void> saveAddress() async {
    // Access Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Construct address data object
    Map<String, dynamic> addressData = {
      'name': nameController.text,
      'phone': phoneController.text,
      'houseNo': housenoController.text,
      'roadName': roadnameController.text,
      'city': cityController.text,
      'state': stateController.text,
      'pincode': pinCodeController.text,
      // Add more fields as needed
    };

    try {
      // Add address data to Firestore
      await firestore.collection('addresses').add(addressData);
      // Show success message or navigate to another screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address saved successfully')),
      );
      // Navigate to another screen if needed
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => PlaceOrderAndOrderSummery()),
        (route) => false,
      );
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save address'),
          duration: Duration(seconds: 3),
        ),
      );
      // Handle error
      print('Error saving address: $error');
    }
  }
}
