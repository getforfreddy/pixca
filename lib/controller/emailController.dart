import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:pixca/view/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/userModel.dart';

class EmailPassController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxBool passwordVisible = true.obs;
  RxBool loading = false.obs;

  void updateLoading() {
    loading.toggle();
  }

  void updateVisibility() {
    passwordVisible.toggle(); // Use toggle method to toggle the value
  }

  FirebaseAuth get auth => _auth;

  Future<void> signupUser(String email, String password, String name, String phone) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
// Check if the email is already registered
      bool isEmailRegistered = await isEmailAlreadyRegistered(email);

      if (!isEmailRegistered) {

        // String newName = name.capitalizeFirst!;
        String newName = name.split(' ')
            .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
            .join(' ');

        await userCredential.user!.updateDisplayName(newName);
        await userCredential.user!.updateEmail(email);

        UserModel userModel = UserModel(
          uId: userCredential.user!.uid,
          username: userCredential.user!.displayName ?? newName,
          email: userCredential.user!.email ?? '',
          phone: userCredential.user!.phoneNumber ?? phone,
          userImg: userCredential.user!.photoURL?.toString() ??
              'https://firebasestorage.googleapis.com/v0/b/pixca-d82c7.appspot.com/o/profile-image%2Fprofile.png?alt=media&token=55da918f-38d0-4cd2-8a24-3567a61367d3',
          country: 'NA',
          userAddress: 'NA',
          createdOn: DateTime.now(),
        );

        try {
          await FirebaseFirestore.instance // Save user data to Firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userModel.toMap());
        } catch (e) {
          print("Error saving user data: $e");
        }
      } else {
        print("Email already registered!");
      }

    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Function to check if the email is already registered
  Future<bool> isEmailAlreadyRegistered(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  User? get currentUser => _auth.currentUser;
  String errorMessage = '';

  Future<UserCredential?> signinUser(
      String userEmail, String userPassword) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      // Save session state
      await saveSession(true);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      }
      update(); // Notify the UI that the errorMessage has changed
    } catch (e) {
      print('Error signing in: $e');
    }
  }


  Future<void> forgotPassword(
    String userEmail,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(email: userEmail);
      Get.snackbar(
        "Request Sent Sucessfully",
        "Password reset link sent to $userEmail",
        snackPosition: SnackPosition.TOP,
      );
      Get.off(const LoginSample(), transition: Transition.leftToRightWithFade);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Error",
        "$e",
        snackPosition: SnackPosition.TOP,
      );
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
