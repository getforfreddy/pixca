import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'login.dart';

class SplashScreenSample extends StatefulWidget {
  const SplashScreenSample({super.key});

  @override
  State<SplashScreenSample> createState() => _SplashScreenSampleState();
}

class _SplashScreenSampleState extends State<SplashScreenSample> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    // TODO: implement initState
    super.initState();
    Timer.periodic(Duration(seconds: 3), (timer) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => LoginSample(),
      ),);
    });
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
                  child: Lottie.asset('assect/animations/splashScreen.json'),
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
