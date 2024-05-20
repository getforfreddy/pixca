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
  List<QueryDocumentSnapshot<Object?>> userData = [];
  late TextEditingController phoneController;
  String? _imageUrl;
  File? _imageFile;
  bool _isEditingPhone = false;
  bool _isEditingImage = false;

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
      _imageUrl = userData[0]['userImg'];
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateUserData({String? newImageUrl}) async {
    if (userData.isNotEmpty) {
      String? downloadUrl;
      if (newImageUrl != null) {
        downloadUrl = newImageUrl;
      } else if (_imageFile != null) {
        var imageName = "Image_${DateTime.now().millisecondsSinceEpoch}";
        var storageRef =
            FirebaseStorage.instance.ref().child('user_images/$imageName.jpg');
        var uploadTask = storageRef.putFile(_imageFile!);
        downloadUrl = await (await uploadTask).ref.getDownloadURL();
      }
      var docId = userData[0].id;
      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'phone': phoneController.text,
        'userImg': downloadUrl ?? _imageUrl,
      });
      await _getUserData();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _updateUserData();
    }
  }

  Future<void> _updatePhone() async {
    await _updateUserData();
    Get.snackbar('Success', 'Phone number updated',
        snackPosition: SnackPosition.BOTTOM);
    setState(() {
      _isEditingPhone = false;
    });
  }

  Future<void> _updateProfile() async {
    await _updateUserData();
    Get.snackbar('Success', 'Profile updated',
        snackPosition: SnackPosition.BOTTOM);
    setState(() {
      _isEditingImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 140),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditingImage = true;
                  });
                },
                child: CircleAvatar(
                  radius: 80.r,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : NetworkImage(
                          _imageUrl ?? 'https://via.placeholder.com/120',
                        ) as ImageProvider,
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: _isEditingImage
                          ? IconButton(
                              onPressed: _updateProfile, icon: Icon(Icons.save))
                          : Icon(
                              Icons.edit,
                              color: Colors.black,
                            )

                      // ElevatedButton.icon(
                      //   onPressed: _updateProfile,
                      //   icon: Icon(Icons.save),
                      //   label: Text('Save'),
                      // )
                      //     : Icon(
                      //   Icons.edit,
                      //   color: Colors.white,
                      // ),
                      ),
                ),
              ),
            ),
            if (_isEditingImage)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Choose Image'),
                ),
              ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "${userData.isNotEmpty ? userData[0]['username'] : 'N/A'}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
              ),
            ),
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
                  readOnly: !_isEditingPhone,
                ),
                shape: OutlineInputBorder(),
                leading: Icon(Icons.phone),
                trailing: _isEditingPhone
                    ? ElevatedButton.icon(
                        onPressed: _updatePhone,
                        icon: Icon(Icons.save, color: Colors.black),
                        label: Text('Save'),
                      )
                    : IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _isEditingPhone = true;
                          });
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
