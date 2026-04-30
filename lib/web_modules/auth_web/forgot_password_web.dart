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
    final size = MediaQuery.of(context).size.width;
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
                width: size > 800 ? 450 : size * 0.85,
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
                            width: size*0.05,
                            height: size*0.05,
                            child: ClipOval(
                              child: loginController.appLogoUrl != null
                                  ? Image.network(
                                loginController.appLogoUrl!,
                                fit: BoxFit.cover,
                                width: size*0.15,
                                height: size*0.12,
                              )
                                  : Container(
                                color: Colors.white.withOpacity(0.3),
                                child:  Icon(
                                  Icons.medical_services,
                                  size: size*0.2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Text(
                            "Forgot Password",
                            style: AppTextStyles.body(context,color: AppColors.white),),
                           SizedBox(height: size*0.01),
                          Text(
                            "Please Enter your Registered Email",
                            style: AppTextStyles.caption(context,color: AppColors.white),),
                          SizedBox(height: size*0.01),

                          passwordField(),
                          SizedBox(height: size*0.02),
                          submitButton(),
                          SizedBox(height: size*0.01),
                          Row(
                            children: [
                              Expanded(
                                  child: Divider(color: Colors.white.withOpacity(0.4))),
                               Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text("OR",
                                    style:
                                    AppTextStyles.caption(context,color: Colors.white70,)),
                              ),
                              Expanded(
                                  child: Divider(color: Colors.white.withOpacity(0.4))),
                            ],
                          ),
                          SizedBox(height: size*0.01),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(color: Colors.white70),
                              ),
                              SizedBox(height: size*0.005),

                              TextButton(
                                  onPressed: () {
                                    Get.offAllNamed('/registerPageWeb');
                                  },
                                  child:  Text(
                                    "Sign Up",
                                    style: AppTextStyles.body(context,
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