import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pixca/controller/emailController.dart';
import 'package:pixca/controller/googleSignInController.dart';
import 'package:pixca/view/signUp.dart';
import 'forgotPassword.dart';
import 'homeScreen.dart';

class LoginSample extends StatefulWidget {
  const LoginSample({super.key});

  @override
  State<LoginSample> createState() => _LoginSampleState();
}

class _LoginSampleState extends State<LoginSample> {
  bool isPasswordVisible = true;
  final login = GlobalKey<FormState>();
  var userNameController = TextEditingController();
  var passwordController = TextEditingController();
  GoogleController googleController = Get.put(GoogleController());

  EmailPassController emailPassController = Get.put(EmailPassController());

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 2,
            title: Center(child: const Text("Login")),
          ),
          body:
              // Image.asset('images/loginSample.png').
              Stack(
            fit: StackFit.expand,
            children: [
              // Image.asset(
              //   'images/loginBg.jpg',
              //   fit: BoxFit.cover,
              // ),
              ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 140),
                    child: Center(
                      child: SizedBox(
                        width: 460,
                        child: Card(
                          elevation: 5,
                          child: Form(
                            key: login,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 170.h,
                                  child: Lottie.asset(
                                      'assect/animations/login.json'),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: SizedBox(
                                    width: 400,
                                    child: TextFormField(
                                      controller: userNameController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Please enter email";
                                        }
                                        return null;
                                      },
                                      style: TextStyle(fontSize: 20),
                                      decoration: InputDecoration(
                                        label: Text("Email"),
                                        hintText: "Enter your email",
                                        border: OutlineInputBorder(),
                                      ),
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
                                        }
                                        return null;
                                      },
                                      style: TextStyle(fontSize: 20.sp),
                                      decoration: InputDecoration(
                                          label: Text("Password"),
                                          border: OutlineInputBorder(),
                                          hintText: "Enter password",
                                          suffixIcon: isPasswordVisible
                                              ? IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      isPasswordVisible =
                                                          !isPasswordVisible;
                                                    });
                                                  },
                                                  icon: Icon(Icons.visibility))
                                              : IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      isPasswordVisible =
                                                          !isPasswordVisible;
                                                    });
                                                  },
                                                  icon: Icon(
                                                      Icons.visibility_off))),
                                      obscureText: isPasswordVisible,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 400.w,
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ForgotPasswordSample(),
                                              ));
                                        },
                                        child: Text(
                                          "Forgot Password ?",
                                          textAlign: TextAlign.right,
                                        )),
                                  ),
                                ),

                                SizedBox(
                                  width: 160.w,
                                  height: 40.h,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (login.currentState!.validate()) {
                                        emailPassController.updateLoading();
                                        try {
                                          UserCredential? userCredential =
                                          await emailPassController.signinUser(
                                            userNameController.text,
                                            passwordController.text,
                                          );
                                          if (userCredential != null &&
                                              userCredential.user!.emailVerified) {
                                            final user = userCredential.user;
                                            Get.offAll(() => const HomeSample(),
                                                transition: Transition.leftToRightWithFade);
                                          }
                                        } catch (e) {
                                          print(e);
                                          Get.snackbar('Error', emailPassController.errorMessage);
                                        } finally {
                                          emailPassController.updateLoading();
                                        }
                                      } else {
                                        // Display the error message in a snackbar if there is one
                                        Get.snackbar('Error', emailPassController.errorMessage);
                                      }
                                    },
                                    child: Text("Login"),
                                  ),
                                ),
                                SizedBox(
                                  height: 100,
                                  width: 240,
                                  child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          googleController.signInWithGoogle();
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Center(
                                            child: SizedBox(
                                                width: 80,
                                                height: 80,
                                                child: Image.asset(
                                                    "assect/images/icones/GoogleSymbol.png")),
                                          ),
                                          Text("Sign in with google"),
                                        ],
                                      )),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SignUpPage(),
                                            ));
                                      },
                                      child: Text("Sign Up")),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
