import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/main.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import '../../../common_widgets/custom_toast.dart';


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
    loginController.emailController.clear();
    loginController.passwordController.clear();
  }

  Future<void> _handleSignIn(BuildContext context, String platform) async {
    if (_formKeyLogin.currentState!.validate()) {
      String email = loginController.emailController.text.trim();
      String password = loginController.passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        showCustomToast(
          context,
          "Please enter email and password",
          backgroundColor: AppColors.secondary,
        );
        return;
      }
      await setupFCM();

      await loginController.login(email, password, platform, context);

      loginController.emailController.clear();
      loginController.passwordController.clear();
    } else {
      showCustomToast(
        context,
        "Invalid email or password",
        backgroundColor: AppColors.secondary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
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
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: GetBuilder<LoginController>(
          init: loginController,
          builder: (controller) {
            return Form(
              key: _formKeyLogin,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: screenHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(28, 60, 28, 40),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: Container(
                                  color: Colors.white,
                                  child: Image.network(
                                    loginController.appLogoUrl ?? "",
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.primaryLight,
                                        child: const Icon(
                                          Icons.local_hospital,
                                          color: AppColors.primary,
                                          size: 36,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              "Welcome Back",
                              style: AppTextStyles.headline1(
                                context,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Login to continue using Locate Your Dentist",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption(
                                context,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Sign In",
                              style: AppTextStyles.subtitle(
                                context,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 20),

                            CustomTextField(
                              hint: "Enter your email",
                              icon: Icons.email_outlined,
                              controller: loginController.emailController,
                              fillColor: Colors.grey.shade100,
                              borderColor: Colors.grey.shade100,
                            ),

                            const SizedBox(height: 18),

                            CustomTextField(
                              hint: "Enter Your Password",
                              icon: Icons.lock_outline,
                              isPassword: true,
                              controller: loginController.passwordController,
                              fillColor: Colors.grey.shade100,
                              borderColor: Colors.grey.shade100,
                            ),

                            const SizedBox(height: 30),

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.secondary,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () =>
                                      _handleSignIn(context, platform),
                                  child: loginController.isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          "Sign In",
                                          style: AppTextStyles.body(
                                            context,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            TextButton(
                              onPressed: () {
                                Get.toNamed('/forgotPasswordPage');
                              },
                              child: Text(
                                "Forgot Password?",
                                style: AppTextStyles.body(
                                  context,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: AppTextStyles.caption(
                                    context,
                                    color: Colors.grey.shade600,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Sign Up",
                                      style: AppTextStyles.caption(
                                        context,
                                        color: AppColors.primary,
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
                            ),
                          ],
                        ),
                      ),
                    ],
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
