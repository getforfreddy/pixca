import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixca/view/homeScreen.dart';
import 'package:pixca/view/login.dart';

import '../controller/emailValidationController.dart';
class EmailValidationScreen extends StatefulWidget {
  final User user;
  const EmailValidationScreen({super.key, required this.user});

  @override
  State<EmailValidationScreen> createState() => _EmailValidationScreenState();
}

class _EmailValidationScreenState extends State<EmailValidationScreen> {
  bool _isSendingVerification = false;
  bool _isSigningOut = false;
  final EmailValidationController _emailValidationController =
  Get.put(EmailValidationController());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
          width: Get.width,
          height: Get.height,
          child: Column(children: [
            const SizedBox(
              height: 10,
            ),
            const Center(
              child: Text(
                'Verify your email address',
                style: TextStyle(
                  fontSize: 18,
                  // color: AppConstant.yellowText,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Name: ${widget.user.displayName}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Roboto-Regular',
                        fontWeight: FontWeight.w400,
                        // color: AppConstant.appTextColor,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Email: ${widget.user.email}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Roboto-Regular',
                        // color: AppConstant.appTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            widget.user.emailVerified
                ? const Center(
              child: Text(
                'Email is verified',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Roboto-Regular',
                  color: Colors.lightGreenAccent,
                ),
              ),
            )
                : const Center(
              child: Text(
                'Email is not verified',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Roboto-Regular',
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            _isSendingVerification
                ? const Center(child: CircularProgressIndicator())
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(const Color(0xFF1F41BB)),
                    ),
                    onPressed: () async {
                      setState(() {
                        _isSendingVerification = true;
                      });
                      await _emailValidationController
                          .sendingEmailVerification(widget.user);
                      setState(() {
                        _isSendingVerification = false;
                      });
                    },
                    child: const Text(
                      'Verify',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Roboto-Regular',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                TextButton.icon(
                  // <-- TextButton
                  onPressed: () async {
                    try {
                      User? user = await _emailValidationController
                          .refreshEmail(widget.user);
                      if (user != null && user.emailVerified) {
                        Get.snackbar('Success : ',
                            'Email has been verified successfully');
                        Get.off(const HomeSample(),
                            transition: Transition.leftToRightWithFade);
                      } else {
                        Get.snackbar('Failed : ',
                            'Email has been not verified check your mail');
                      }
                    } catch (e) {}
                  },
                  icon: const Icon(
                    Icons.refresh,
                    size: 24,
                    color: Color(0xFF1F41BB),
                  ),
                  label: const Text(
                    'Check',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Roboto-Regular',
                      // color: AppConstant.appTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            _isSigningOut
                ? const Center(child: CircularProgressIndicator())
                : Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey),
                ),
                onPressed: () async {
                  setState(() {
                    _isSigningOut = true;
                  });
                  await FirebaseAuth.instance.signOut();
                  setState(() {
                    _isSigningOut = false;
                    Get.off(const LoginSample(),
                        transition: Transition.rightToLeftWithFade);
                  });
                },
                child: const Text(
                  'Sign out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}