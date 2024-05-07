import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pixca/view/homeScreen.dart';
import 'package:pixca/view/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/userModel.dart';

class GoogleController extends GetxController {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final _googelSignin = GoogleSignIn();
  Rx<User?> user = Rx<User?>(null);

  Future<void> signInWithGoogle() async {
    // final GetDeviceTokenController getDeviceTokenController =
    // Get.put(GetDeviceTokenController());
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        // EasyLoading.show(status: "Please wait..");
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential userCredential =
            await firebaseAuth.signInWithCredential(credential);
        final User? user = userCredential.user;

        // Save session state
        await saveSession(true);

        if (user != null) {
          UserModel userModel = UserModel(
            uId: user.uid,
            username: user.displayName?.toString() ?? 'NA',
            email: user.email?.toString() ?? 'NA',
            phone: user.phoneNumber?.toString() ?? 'xxxxxxxxxx',
            userImg: user.photoURL?.toString() ??
                'https://firebasestorage.googleapis.com/v0/b/pixca-d82c7.appspot.com/o/profile-image%2Fprofile.png?alt=media&token=55da918f-38d0-4cd2-8a24-3567a61367d3',
            country: 'NA',
            userAddress: 'NA',
            createdOn: DateTime.now(),
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userModel.toMap());
          // EasyLoading.dismiss();
          Get.offAll(() => const HomeSample());
        }
      }
    } catch (e) {
      //EasyLoading.dismiss();
      print("error $e");
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      await googleSignIn.signOut();
      await _googelSignin.signOut();
      user(null);
      print("User Signed Out");

      // Clear session state
      await saveSession(false);

      Get.offAll(() => const LoginSample());
    } catch (e) {
      print("Errir Signing Out: $e");
    }
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> saveSession(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

}
