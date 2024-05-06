import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pixca/controller/googleSignInController.dart';
import 'package:pixca/view/login.dart';

import '../controller/getUserDataController.dart';

class ProfileSample extends StatefulWidget {
  const ProfileSample({super.key});

  @override
  State<ProfileSample> createState() => _ProfileSampleState();
}

class _ProfileSampleState extends State<ProfileSample> {
  final GoogleController googleController = GoogleController();
  final GetUserDataController _getUserDadtaController =
      Get.put(GetUserDataController());

  late final User user;
  late List<QueryDocumentSnapshot<Object?>> userData = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _getUserData();
  }

  Future<void> _getUserData() async {
    userData = await _getUserDadtaController.getUserData(user.uid);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 140),
            child: CircleAvatar(
              radius: 80.r,
              backgroundImage: NetworkImage(
                userData.isNotEmpty &&
                        userData[0]['userImg'] != null &&
                        userData[0]['userImg'].isNotEmpty
                    ? userData[0]['userImg']
                    : 'https://via.placeholder.com/120',
              ),
            ),
          ),
          Center(
              child: Text(
            "${userData.isNotEmpty ? userData[0]['username'] : 'N/A'}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
          )),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: ListTile(
              title: Text(
                '${userData.isNotEmpty ? userData[0]['email'] : 'N/A'}',
              ),
              shape: OutlineInputBorder(),
              leading: Icon(Icons.email_outlined),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(18.0),
              child: ListTile(
                title: Text(
                    "${userData.isNotEmpty ? userData[0]['phone'] : 'N/A'}"),
                shape: OutlineInputBorder(),
                leading: Icon(Icons.phone),
              )),

        ],
      ),
    );
  }
}
