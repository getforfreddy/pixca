import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pixca/view/emailValidationScreen.dart';

import '../controller/emailController.dart';
import '../controller/googleSignInController.dart';
import 'homeScreen.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isPassVisible = true;
  bool isPasswordVisible = true;
  var passwordController = TextEditingController();
  var conPasswordController = TextEditingController();

  final registrationkey = GlobalKey<FormState>();

  var nameController = TextEditingController();
  var emailController = TextEditingController();

  final GoogleController _googleSignInController =
  Get.put(GoogleController());
  final EmailPassController _emailPassController =
  Get.put(EmailPassController());

  var userNamergx = RegExp(
      r"(^[A-Za-z]{3,16})([ ]{0,1})([A-Za-z]{3,16})?([ ]{0,1})?([A-Za-z]{3,16})?([ ]{0,1})?([A-Za-z]{3,16})");
  var emailAddress = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
  var passwordrgx = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*?_~]).{8,}$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registration form"),
        backgroundColor: Colors.white,
        elevation: 5,
      ),
      body: ListView(
        children: [
          Form(
            key: registrationkey,
            child: Column(
              children: [
                SizedBox(
                    height: 170.h,
                    width: 150.w,
                    child: Lottie.asset('assect/animations/signUp.json')),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 400,
                    child: TextFormField(
                      controller: nameController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your name";
                        } else if (!userNamergx.hasMatch(value)) {
                          return "please enter your fullname";
                        }
                        return null;
                      },
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        label: Text("Name"),
                        border: OutlineInputBorder(),
                        hintText: "Enter your name",
                      ),
                      keyboardType: TextInputType.name,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 400,
                    child: TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter email id";
                        } else if (!emailAddress.hasMatch(value)) {
                          return "Enter a valid email id";
                        }
                        return null;
                      },
                      style: TextStyle(fontSize: 20),
                      cursorColor: Colors.green,
                      decoration: InputDecoration(
                        label: Text("Email Id"),
                        border: OutlineInputBorder(),
                        hintText: "Enter email id",
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 400,
                    child: TextFormField(
                      controller: passwordController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter password";
                        } else if (!passwordrgx.hasMatch(value)) {
                          return "please enter a strong password ";
                        }
                        return null;
                      },
                      style: TextStyle(fontSize: 20.sp),
                      cursorColor: Colors.green,
                      // cursorHeight: 40,
                      // cursorWidth: 10,
                      decoration: InputDecoration(
                          label: Text("Password"),
                          border: OutlineInputBorder(),
                          hintText: "Enter password",
                          suffixIcon: isPassVisible
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPassVisible = !isPassVisible;
                                    });
                                  },
                                  icon: Icon(Icons.visibility))
                              : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPassVisible = !isPassVisible;
                                    });
                                  },
                                  icon: Icon(Icons.visibility_off))),
                      obscureText: isPassVisible,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 400,
                    child: TextFormField(
                      controller: conPasswordController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please re-enter password";
                        }
                        return null;
                      },
                      style: TextStyle(fontSize: 20.sp),
                      cursorColor: Colors.green,
                      // cursorHeight: 40,
                      // cursorWidth: 10,
                      decoration: InputDecoration(
                          label: Text("Confirm password"),
                          border: OutlineInputBorder(),
                          hintText: "Confirm password",
                          suffixIcon: isPasswordVisible
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                  icon: Icon(Icons.visibility))
                              : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                  icon: Icon(Icons.visibility_off))),
                      obscureText: isPasswordVisible,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextButton(
                      onPressed: () async {
                        if (registrationkey.currentState!.validate()) {
                          _emailPassController.updateLoading();
                          try {
                            await _emailPassController.signupUser(
                              emailController.text,
                              passwordController.text,
                              nameController.text,
                            );
                            if (_emailPassController.currentUser !=
                                null) {
                              Get.off(
                                      () => EmailValidationScreen(
                                      user: _emailPassController
                                          .currentUser!),
                                  transition:
                                  Transition.leftToRightWithFade);
                            } else {
                              // No user is currently authenticated
                              Get.snackbar('No user is',
                                  'currently authenticated');
                            }
                          } catch (e) {
                            Get.snackbar('Error', e.toString());
                          } finally {
                            _emailPassController.updateLoading();
                          }
                        }
                      },
                      child: Text("SignUp")),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginSample(),
                            ));
                      },
                      child: Text("Alredy have an account? Login")),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
