
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';


class ForgotChangePasswordPage extends StatefulWidget {
  const ForgotChangePasswordPage({super.key});

  @override
  State<ForgotChangePasswordPage> createState() => _ForgotChangePasswordPageState();
}

class _ForgotChangePasswordPageState extends State<ForgotChangePasswordPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final loginController=Get.put(LoginController());

  final _formKeyForgotWeb = GlobalKey<FormState>();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  String? confirmPasswordValidator(
      String? value, TextEditingController passwordController) {
    if (value == null || value.isEmpty) return "Confirm Password cannot be empty";
    if (value != passwordController.text) return "Passwords do not match";
    return null;
  }

  // Common Password Field
  Widget passwordField() {
    return   CustomTextField(
      hint: "Password",
      icon: Icons.lock,
      isPassword: true,
      controller: loginController.passwordController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password cannot be empty";
        }
        if (value.length < 4) {
          return "Password must be at least 4 characters";
        }
        // if (!RegExp(r'[a-z]').hasMatch(value)) {
        //   return "Password must contain at least one lowercase letter";
        // }
        // if (!RegExp(r'[A-Z]').hasMatch(value)) {
        //   return "Password must contain at least one uppercase letter";
        // }
        // if (!RegExp(r'[0-9]').hasMatch(value)) {
        //   return "Password must contain at least one number";
        // }
        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
          return "Password must contain at least one special character";
        }
        return null;
      },
    );
  }

  // Common Confirm Password Field
  Widget confirmPasswordField() {
    return CustomTextField(
      hint: "Confirm Password",
      icon: Icons.lock,
      isPassword: true,
      controller: loginController.confirmPasswordController,
      validator: (value) => confirmPasswordValidator(value, loginController.passwordController),
    );
  }

  // Submit Button
  Widget submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (_formKeyForgotWeb.currentState!.validate()) {
            loginController.forgotChangePassword(
              Api.userInfo.read('otpMail') ?? "",
              loginController.confirmPasswordController.text,
              context,
            );
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
    String platform = kIsWeb
        ? "Web"
        : Platform.isAndroid
        ? "Android"
        : Platform.isIOS
        ? "iOS"
        : "Unknown";
    return Scaffold(
      body: Form(
        key: _formKeyForgotWeb,
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
                          "Change Password",
                          style: AppTextStyles.body(context),),
                         const SizedBox(height: 10),
                         Text(
                          "Forgot Password",
                        style: AppTextStyles.caption(context,color: AppColors.white),),
                        const SizedBox(height: 30),

                        const SizedBox(height: 30),
                        passwordField(),
                        const SizedBox(height: 20),
                        confirmPasswordField(),
                        const SizedBox(height: 30),
                        submitButton(),
                        const SizedBox(height: 20),

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