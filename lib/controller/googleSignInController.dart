import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pixca/view/homeScreen.dart';

import '../model/userModel.dart';
class GoogleController extends GetxController {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final _googelSignin = GoogleSignIn();
  Rx<User?>user = Rx<User?>(null);

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
        if (user != null) {
          UserModel userModel = UserModel(
            uId: user.uid,
            username: user.displayName.toString(),
            email: user.email.toString(),
            phone: user.phoneNumber.toString(),
            userImg: user.photoURL.toString(),
            // userDeviceToken: getDeviceTokenController.deviceToken.toString(),
            country: '',
            userAddress: '',

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
}
