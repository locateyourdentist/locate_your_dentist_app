import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import '../../../common_widgets/custom_toast.dart';

//sxsd
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKeyLogin = GlobalKey<FormState>();
  DateTime? currentBackPressTime;
  final loginController = Get.put(LoginController());
  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      //CommonDialog.showExitDialog(context);
      Get.toNamed('/patientDashboard');
      return true;
    }
    exit(0);
  }

  @override
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    String platform = kIsWeb
        ? "Web"
        : Platform.isAndroid
        ? "Android"
        : Platform.isIOS
        ? "iOS"
        : "Unknown";
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: GetBuilder<LoginController>(
          init: loginController,
          builder: (controller) {
            return Form(
              key: _formKeyLogin,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  // color: AppColors.white
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      // Color(0xff0F172A),
                      // Color(0xff1E293B),
                      //Color(0xff2563EB),
                      AppColors.primary, AppColors.primary,
                    ],
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 450),
                      margin: const EdgeInsets.all(20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Center(
                              //   child: ClipRRect(
                              //     borderRadius: BorderRadius.circular(10),
                              //     child: Image.network(
                              //       loginController.appLogoUrl ?? "",
                              //       // AppConstants.logoUrl,
                              //       width: size * 0.35,
                              //       height: size * 0.35,
                              //       fit: BoxFit.cover,
                              //       errorBuilder: (context, error, stackTrace) {
                              //         return Container(
                              //             height: 90,
                              //             width: 90,
                              //             decoration: BoxDecoration(
                              //               color: AppColors.secondary,
                              //               borderRadius: BorderRadius.circular(25),
                              //             ),
                              //             child: const Icon(
                              //               Icons.local_hospital,
                              //               color: AppColors.white,
                              //               size: 50,
                              //             ),
                              //           );
                              //       },
                              //     ),
                              //   ),
                              // ),
                              Center(
                                child: Container(
                                  width: size * 0.35,
                                  height: size * 0.35,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      loginController.appLogoUrl ?? "",
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: AppColors.secondary,
                                              child: const Icon(
                                                Icons.local_hospital,
                                                color: AppColors.white,
                                                size: 50,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),

                              Text(
                                "LYD",
                                style: AppTextStyles.headline1(
                                  context,
                                  color: AppColors.white,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "Welcome Back",
                                style: AppTextStyles.subtitle(
                                  context,
                                  color: AppColors.white,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Login to continue using Locate Your Dentist",
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption(
                                  context,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 35),

                              CustomTextField(
                                hint: "Enter your email",
                                icon: Icons.email_outlined,
                                controller: loginController.emailController,
                              ),

                              const SizedBox(height: 25),

                              CustomTextField(
                                hint: "Enter Your Password",
                                icon: Icons.lock_outline,
                                isPassword: true,
                                controller: loginController.passwordController,
                              ),

                              const SizedBox(height: 50),

                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKeyLogin.currentState!
                                        .validate()) {
                                      String email = loginController
                                          .emailController
                                          .text
                                          .trim();
                                      String password = loginController
                                          .passwordController
                                          .text;

                                      if (email.isEmpty || password.isEmpty) {
                                        showCustomToast(
                                          context,
                                          "Please enter email and password",
                                          backgroundColor: AppColors.secondary,
                                        );
                                        return;
                                      }

                                      await loginController.login(
                                        email,
                                        password,
                                        platform,
                                        context,
                                      );

                                      loginController.emailController.clear();
                                      loginController.passwordController
                                          .clear();
                                    } else {
                                      showCustomToast(
                                        context,
                                        "Invalid email or password",
                                        backgroundColor: AppColors.secondary,
                                      );
                                    }
                                  },
                                  child: loginController.isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          "Sign In",
                                          style: AppTextStyles.body(
                                            context,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 25),

                              TextButton(
                                onPressed: () {
                                  Get.toNamed('/forgotPasswordPage');
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: AppTextStyles.body(
                                    context,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: AppTextStyles.caption(
                                    context,
                                    color: Colors.white70,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Sign Up",
                                      style: AppTextStyles.caption(
                                        context,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.toNamed('/registerPage');
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
