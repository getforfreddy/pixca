import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class EmailValidationController extends GetxController {
  final FirebaseAuth fireAuth = FirebaseAuth.instance;

  Future<void> sendingEmailVerification(User? currentUser) async {
    if (currentUser != null) {
      if (!currentUser.emailVerified) {
        try {
          await currentUser.sendEmailVerification();
          Get.snackbar('Success', 'Email verification sent to your email');
        } catch (e) {
          Get.snackbar('Error', 'Failed to send email verification');
        }
      }
    }
  }

  Future<User?> refreshEmail(User currentUser) async {
    // Reload the current user to ensure you have the latest data
    await currentUser.reload();

    // Get the current user from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;

    // Update Firestore document
    if (user != null) {
      bool emailVerified = user.emailVerified;

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'verified': emailVerified}, SetOptions(merge: true));
    }

    return user;
  }
}