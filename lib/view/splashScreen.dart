import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import 'package:pixca/view/homeScreen.dart';

import 'login.dart';

class SplashScreenSample extends StatefulWidget {
  const SplashScreenSample({super.key});

  @override
  State<SplashScreenSample> createState() => _SplashScreenSampleState();
}

class _SplashScreenSampleState extends State<SplashScreenSample> {
  late User? user;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    // Delay for 7 seconds before checking login status
    Future.delayed(Duration(seconds: 3), () {
      logInCheck(context);
    });
  }

  Future<void> logInCheck(BuildContext context) async {
    // Get current user
    user = FirebaseAuth.instance.currentUser;

    // Check if user is logged in
    if (user != null) {
      // User is logged in, navigate to HomeScreen
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeSample()),
      );
    } else {
      // User is not logged in, navigate to LoginScreen
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginSample()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(
              height: 350.h,
              width: 350.w,
              child: Padding(
                padding: const EdgeInsets.only(top: 225),
                child: Center(
                  child: Lottie.asset('assect/animations/logoSplash.json'),
                ),
              )),
          TextButton(
              onPressed: () {},
              child: Text(
                "Pixca",
                style: TextStyle(
                    fontSize: 80,
                    color: Colors.black26,
                    fontFamily: "DancingScript"),
              ))
        ],
      ),
    );
  }
}
