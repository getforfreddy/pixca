import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class PaymentSample extends StatefulWidget {
  const PaymentSample({super.key});

  @override
  State<PaymentSample> createState() => _PaymentSampleState();
}

class _PaymentSampleState extends State<PaymentSample> {
  String? address;
  Position? _position;

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

  Future<void>getCurrentLocation()async{
    final HasPermission= await checkPermissionPhone();
    if(!HasPermission ) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
    .then((Position position){
      setState(() {
        _position=position;
        _getAddressFromLatLng(_position!);
      });
    }).catchError((e){

    });
  }


  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
        _position!.latitude, _position!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        address =
        '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}, ${place.country}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text("Address:  ${address?? ''}"),
          ElevatedButton(onPressed: () {
            getCurrentLocation();
          }, child: Text("Use my location"))
        ],
      ),
    );
  }
}
