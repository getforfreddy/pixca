import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
class DeliveryLocationMarkingPage extends StatefulWidget {
  const DeliveryLocationMarkingPage({super.key});

  @override
  State<DeliveryLocationMarkingPage> createState() => _DeliveryLocationMarkingPageState();
}

class _DeliveryLocationMarkingPageState extends State<DeliveryLocationMarkingPage> {
  String? address, pincode, state, houseno, city, roadname;
  Position? _position;

  TextEditingController pinCodeController=TextEditingController();
  TextEditingController housenoController=TextEditingController();
  TextEditingController nameController=TextEditingController();
  TextEditingController phoneController=TextEditingController();
  TextEditingController cityController=TextEditingController();

  TextEditingController roadnameController=TextEditingController();
  TextEditingController stateController=TextEditingController();


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
        address =
        '${place.street}, ${place.subLocality},'
            ' ${place.postalCode}, '
            '${place.administrativeArea},${place.name}';
        pincode=place.postalCode;
        houseno=place.name;
        roadname=place.street;
        city=place.subLocality;
        state= place.administrativeArea;
        housenoController.text=houseno.toString();
        roadnameController.text=roadname.toString();
        cityController.text=city.toString();
        stateController.text=state.toString();
        pinCodeController.text=pincode.toString();
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Address"),
      ),
      body: Column(
        children: [
          Text(
            "${address ?? ''}",
            style: TextStyle(fontSize: 20),
          ),
          Form(child: Column(
            children: [

              TextFormField(
                controller: housenoController,
                decoration:
                InputDecoration(
                    label: Text("House number")
                ),
              ),
              TextFormField(
                controller: roadnameController,
                decoration:
                InputDecoration(
                    label: Text("LandMark")
                ),
              ),
              TextFormField(
                controller: cityController,
                decoration:
                InputDecoration(
                    label: Text("Road name or area")
                ),
              ),
              TextFormField(
                controller: stateController,
                decoration:
                InputDecoration(
                    label: Text("State")
                ),
              ),
              TextFormField(
                controller: pinCodeController,
                decoration:
                InputDecoration(
                    label: Text("Pincode")
                ),
              ),
            ],
          )),
          ElevatedButton(
              onPressed: () {
                getCurrentLocation();
              },
              child: Text("Use my location"))

        ],
      ),
    );
  }
}

