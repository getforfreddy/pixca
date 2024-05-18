import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/getUserDataController.dart';
import '../controller/googleSignInController.dart';

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
  late TextEditingController phoneController;
  File? _imageUrl;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _getUserData();
  }

  Future<void> _getUserData() async {
    userData = await _getUserDadtaController.getUserData(user.uid);
    if (userData.isNotEmpty) {
      phoneController = TextEditingController(text: userData[0]['phone']);
      _imageUrl = userData[0]['userImg'];
    } else {
      phoneController = TextEditingController();
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateUserData() async {
    if (userData.isNotEmpty) {

      var imageName = "Image"+DateTime.now().millisecondsSinceEpoch.toString();
      var storageRef = FirebaseStorage.instance.ref().child('user_images/$imageName.jpg');
      var uploadTask = storageRef.putFile(_imageUrl!);
      var downloadUrl = await (await uploadTask).ref.getDownloadURL();
      var docId = userData[0].id;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .update({'phone': phoneController.text, 'userImg': downloadUrl.toString() ?? ''});
      await _getUserData();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // For simplicity, we'll use the picked file's path directly
      // In a real app, you should upload this image to a server or a cloud storage
      setState(() {
        _imageUrl = File(pickedFile.path);
      });
      await _updateUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.save),
          //   onPressed: _updateUserData,
          // ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 140),
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 80.r,
                  backgroundImage:

                  // _imageUrl != null
                  //     ? FileImage(_imageUrl!)
                  //     :
                  //

                  NetworkImage(
                    userData.isNotEmpty &&
                        userData[0]['userImg'] != null &&
                        userData[0]['userImg'].isNotEmpty
                        ? userData[0]['userImg']
                        : 'https://via.placeholder.com/120',
                  ) as ImageProvider,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
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
                title: TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                shape: OutlineInputBorder(),
                leading: Icon(Icons.phone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
