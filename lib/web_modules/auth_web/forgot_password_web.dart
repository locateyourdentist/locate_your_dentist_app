// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:locate_your_dentist/api/api.dart';
// import 'package:locate_your_dentist/common_widgets/color_code.dart';
// import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
// import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
//
// class ForgotChangePasswordWeb extends StatefulWidget {
//   const ForgotChangePasswordWeb({super.key});
//
//   @override
//   State<ForgotChangePasswordWeb> createState() =>
//       _ForgotChangePasswordWebState();
// }
//
// class _ForgotChangePasswordWebState extends State<ForgotChangePasswordWeb> {
//   final loginController = Get.put(LoginController());
//   final _formKey = GlobalKey<FormState>();
//   bool passwordVisible = false;
//   bool confirmPasswordVisible = false;
//
//   String? confirmPasswordValidator(
//       String? value, TextEditingController passwordController) {
//     if (value == null || value.isEmpty) return "Confirm Password cannot be empty";
//     if (value != passwordController.text) return "Passwords do not match";
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFE0EAFB), Color(0xFFF8FAFC)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Container(
//               width: width > 900 ? 500 : width * 0.9,
//               padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(24),
//                 color: Colors.white.withOpacity(0.95),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // App Logo
//                     Image.asset(
//                       'assets/images/logo.jpg',
//                       width: 160,
//                       height: 120,
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       "Change Password",
//                       style: AppTextStylesWeb.body(context,
//                           color: AppColors.primary, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 30),
//
//                     // New Password
//                     TextFormField(
//                       controller: loginController.passwordController,
//                       obscureText: !passwordVisible,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) return "Password cannot be empty";
//                         if (value.length < 6) return "Password must be at least 6 characters";
//                         if (!RegExp(r'[a-z]').hasMatch(value)) return "Must contain lowercase letter";
//                         if (!RegExp(r'[A-Z]').hasMatch(value)) return "Must contain uppercase letter";
//                         if (!RegExp(r'[0-9]').hasMatch(value)) return "Must contain number";
//                         if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return "Must contain special character";
//                         return null;
//                       },
//                       decoration: InputDecoration(
//                         labelText: 'New Password',
//                         floatingLabelBehavior: FloatingLabelBehavior.auto,
//                         prefixIcon: const Icon(Icons.lock_outline),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             passwordVisible ? Icons.visibility : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               passwordVisible = !passwordVisible;
//                             });
//                           },
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey.shade100,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//
//                     // Confirm Password
//                     TextFormField(
//                       controller: loginController.confirmPasswordController,
//                       obscureText: !confirmPasswordVisible,
//                       validator: (value) => confirmPasswordValidator(
//                           value, loginController.passwordController),
//                       decoration: InputDecoration(
//                         labelText: 'Confirm Password',
//                         floatingLabelBehavior: FloatingLabelBehavior.auto,
//                         prefixIcon: const Icon(Icons.lock_outline),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             confirmPasswordVisible
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               confirmPasswordVisible = !confirmPasswordVisible;
//                             });
//                           },
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey.shade100,
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//
//                     // Gradient Submit Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           if (_formKey.currentState!.validate()) {
//                             loginController.forgotChangePassword(
//                               Api.userInfo.read('otpMail') ?? "",
//                               loginController.confirmPasswordController.text,
//                               context,
//                             );
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.all(0),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           backgroundColor: Colors.transparent,
//                           elevation: 5,
//                         ),
//                         child: Ink(
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [AppColors.primary, AppColors.secondary],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Container(
//                             alignment: Alignment.center,
//                             child: Text(
//                               "Submit",
//                               style: AppTextStylesWeb.caption(
//                                 context,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final loginController=Get.put(LoginController());

  final _formKeyForgotEmailWeb = GlobalKey<FormState>();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  Widget passwordField() {
    return   CustomTextField(
      hint: "Email",
      icon: Icons.email,
      //isPassword: true,
      controller: loginController.emailController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Email cannot be empty";
        }
        return null;
      },
    );
  }

  // Submit Button
  Widget submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async{
          if (_formKeyForgotEmailWeb.currentState!.validate()) {
            Api.userInfo.write('otpMail', loginController.emailController.text);
            await loginController.forgotPassword(loginController.emailController.text,context);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.transparent,
          elevation: 5,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "Submit",
              style: AppTextStyles.caption(
                context,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
  }
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Form(
        key: _formKeyForgotEmailWeb,
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
                child:  GetBuilder<LoginController>(
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

                          Text(
                            "Forgot Password",
                            style: AppTextStyles.body(context),),
                          const SizedBox(height: 10),
                          Text(
                            "Please Enter your Registered Email",
                            style: AppTextStyles.caption(context,color: AppColors.white),),
                          const SizedBox(height: 30),

                          const SizedBox(height: 30),
                          passwordField(),
                          const SizedBox(height: 30),
                          submitButton(),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                  child: Divider(color: Colors.white.withOpacity(0.4))),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text("OR",
                                    style:
                                    TextStyle(color: Colors.white70, fontSize: 14)),
                              ),
                              Expanded(
                                  child: Divider(color: Colors.white.withOpacity(0.4))),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(color: Colors.white70),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Get.offAllNamed('/');
                                  },
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )),
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
    );
  }
}