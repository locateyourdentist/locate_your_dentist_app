import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final loginController = Get.put(LoginController());
  final _formKeyForgotPassword = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKeyForgotPassword,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60),
                  Center(
                    child: Container(
                      width: size * 0.35,
                      height: size * 0.35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          loginController.appLogoUrl ?? "",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
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

                  const SizedBox(height: 30),

                  const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Enter your registered mobile number and we'll send you an OTP to reset your password.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 40),
                  CustomTextField(
                    hint: "Email",
                    icon: Icons.email,
                    controller: loginController.emailController,
                    keyboardType: TextInputType.emailAddress,
                    fillColor: Colors.white,
                    borderColor: Colors.black54,
                  ),
                  SizedBox(height: size * 0.1),

                  Center(
                    child: Container(
                      width: size,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.transparent,
                          shadowColor: AppColors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: loginController.isLoading
                            ? null
                            : () async {
                                if (_formKeyForgotPassword.currentState!
                                    .validate()) {
                                  Api.userInfo.write(
                                    'otpMail',
                                    loginController.emailController.text,
                                  );
                                  await loginController.forgotPassword(
                                    loginController.emailController.text,
                                    context,
                                  );
                                }
                              },
                        child: loginController.isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Send OTP',
                                style: AppTextStyles.caption(
                                  context,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: size * 0.06),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Divider(thickness: 0.4, color: AppColors.grey),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "OR",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption(context),
                          ),
                        ),
                        const Expanded(
                          child: Divider(thickness: 0.4, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size * 0.12),

                  TextButton.icon(
                    onPressed: () {
                      Get.back();
                      // Get.offAllNamed('/verifyPasswordPage');
                    },
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                    label: const Text("Back to Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
