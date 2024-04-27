import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class ForgotPasswordSample extends StatefulWidget {
  const ForgotPasswordSample({super.key});

  @override
  State<ForgotPasswordSample> createState() => _ForgotPasswordSampleState();
}

class _ForgotPasswordSampleState extends State<ForgotPasswordSample> {
  final forgotKey = GlobalKey<FormState>();
  var emailController = TextEditingController();

  var emailAddressForgot =
      RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
      ),
      body: ListView(
        children: [
          Center(
            child: SizedBox(
                height: 170.h,
                width: 250.w,
                child: Lottie.asset('')),
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Text(
              "Enter the email address associated with your account and we'll send you a link to reset your password.",
              style: TextStyle(
                fontSize: 18.r,
              ),
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: forgotKey,
              child: SizedBox(
                width: 400.r,
                child: TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your email id";
                    } else if (!emailAddressForgot.hasMatch(value)) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                  style: TextStyle(fontSize: 20.r),
                  decoration: InputDecoration(
                    label: Text("Email"),
                    hintText: "Please enter your Email",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: 270.r,
              height: 40.r,
              child: ElevatedButton(
                  onPressed: () {
                    if (forgotKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Success'),
                        duration: Duration(seconds: 3),
                      ));
                    }
                  },
                  child: Text("Submit")),
            ),
          ),
        ],
      ),
    );
  }
}
