import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';


class WebLoginPage extends StatefulWidget {
  WebLoginPage({super.key});
  @override
  State<WebLoginPage> createState() => _WebLoginPageState();
}
class _WebLoginPageState extends State<WebLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final loginController=Get.put(LoginController());
  DateTime? currentBackPressTime;
  final _formKeyLoginWeb = GlobalKey<FormState>();
  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      //CommonDialog.showExitDialog(context);
      Get.toNamed('/landingPage');
      return true;
    }
    exit(0);
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
        body: Form(
          key: _formKeyLoginWeb,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary,AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Centered glass card
              Center(
                child: Container(
                  width: size.width > 800 ? 450 : size.width * 0.85,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: GetBuilder<LoginController>(
                      init: loginController,
                      builder: (controller) {
                        return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: ClipOval(
                              child: loginController.appLogoUrl != null
                                  ? Image.network(
                                loginController.appLogoUrl!,
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                              )
                                  : Container(
                                color: Colors.white.withOpacity(0.3),
                                child: const Icon(
                                  Icons.medical_services,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Login to your account",
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 30),

                          // Email field
                          TextField(
                            controller: loginController.emailController,
                            style:  const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Email",
                              hintStyle: AppTextStyles.caption(context,color: AppColors.white),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none),
                              prefixIcon:  const Icon(Icons.email, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password field
                          TextField(
                            controller: loginController.passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle: AppTextStyles.caption(context,color: AppColors.white),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none),
                              prefixIcon: const Icon(Icons.lock, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                                onPressed: () {
                                  Get.toNamed('/forgotPasswordEmailWeb');
                                },
                                child:  Text("Forgot Password?",
                                    style: AppTextStyles.caption(context,color: AppColors.white))),
                          ),
                          const SizedBox(height: 20),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async{

                                if (_formKeyLoginWeb.currentState!
                                    .validate()) {
                                  String email = loginController.emailController
                                      .text.trim();
                                  String password = loginController.passwordController
                                      .text;

                                  if (email.isEmpty ||
                                      password.isEmpty) {
                                    showCustomToast(context, "Please enter email and password",backgroundColor: AppColors.secondary);

                                    // ScaffoldMessenger
                                    //     .of(context)
                                    //     .showSnackBar(
                                    //   const SnackBar(
                                    //       content: Text(
                                    //           "Please enter email and password")),
                                    // );
                                    return;
                                  }
                                  await loginController.login(
                                      loginController.emailController.text.toString(),
                                      loginController.passwordController.text.toString(),platform,context);
                                  loginController.emailController.clear();
                                  loginController.passwordController.clear();
                                } else {
                                  showCustomToast(context,  "Invalid email or password",backgroundColor: AppColors.secondary);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child:  Text(
                                "Login",
                                style:
                                AppTextStyles.caption(context,color: AppColors.primary,fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                  child: Divider(color: Colors.white.withOpacity(0.4))),
                               Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text("OR",
                                    style: AppTextStyles.caption(context,color: AppColors.white),
                              ),),
                              Expanded(
                                  child: Divider(color: Colors.white.withOpacity(0.4))),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               Text(
                                "Don't have an account? ",
                                style: AppTextStyles.caption(context,color: AppColors.white),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Get.toNamed('/registerPageWeb');
                                  },
                                  child:  Text("Sign Up", style: AppTextStyles.body(context,fontWeight:FontWeight.bold,color: AppColors.white),
                        ),)
                            ],
                          ),
                        ],
                      );
                    }
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}