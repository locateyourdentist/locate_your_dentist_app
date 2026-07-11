import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';

class ForgotPasswordPageWeb extends StatefulWidget {
  const ForgotPasswordPageWeb({super.key});

  @override
  State<ForgotPasswordPageWeb> createState() => _ForgotPasswordPageWebState();
}

class _ForgotPasswordPageWebState extends State<ForgotPasswordPageWeb> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final loginController = Get.put(LoginController());

  final _formKeyForgotEmailWeb = GlobalKey<FormState>();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  Widget passwordField() {
    return CustomTextField(
      hint: "",
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
        onPressed: () async {
          if (_formKeyForgotEmailWeb.currentState!.validate()) {
            Api.userInfo.write('otpMail', loginController.emailController.text);
            await loginController.forgotPassword(
              loginController.emailController.text,
              context,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    // Everything inside the card below should scale off the card's own
    // width, not the full screen width — the card is capped at 450px, so
    // on a wide desktop screen `size * 0.0X` produces an oversized avatar
    // that overflows the available height on shorter viewports.
    final double cardWidth = size > 800 ? 450 : size * 0.85;
    final double avatarRadius = (cardWidth * 0.12).clamp(28.0, 40.0);
    return Scaffold(
      body: Form(
        key: _formKeyForgotEmailWeb,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Centered glass card
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                width: cardWidth,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: GetBuilder<LoginController>(
                  init: loginController,
                  builder: (controller) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: Colors.white,
                          backgroundImage: loginController.appLogoUrl != null
                              ? NetworkImage(loginController.appLogoUrl!)
                              : null,
                          child: loginController.appLogoUrl == null
                              ? Icon(
                            Icons.medical_services,
                            size: avatarRadius * 0.85,
                            color: Colors.grey,
                          )
                              : null,
                        ),
                        const SizedBox(height: 20),

                        Text(
                          "Forgot Password",
                          style: AppTextStyles.body(
                            context,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: cardWidth * 0.01),
                        Text(
                          "Please Enter your Registered Email",
                          style: AppTextStyles.caption(
                            context,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: cardWidth * 0.01),

                        passwordField(),
                        SizedBox(height: cardWidth * 0.02),
                        submitButton(),
                        SizedBox(height: cardWidth * 0.01),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "OR",
                                style: AppTextStyles.caption(
                                  context,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: cardWidth * 0.01),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.white70),
                            ),
                            SizedBox(height: cardWidth * 0.005),

                            TextButton(
                              onPressed: () {
                                Get.offAllNamed('/registerPageWeb');
                              },
                              child: Text(
                                "Sign Up",
                                style: AppTextStyles.body(
                                  context,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
