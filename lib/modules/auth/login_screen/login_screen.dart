import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:get/get.dart';
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
 final loginController=Get.put(LoginController());
  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      //CommonDialog.showExitDialog(context);
       Get.toNamed('/patientDashboard');
      return true;
    }
    exit(0);
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
        body:  Form(
          key: _formKeyLogin,
          child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Container(
                    //width: double.infinity,
                    //height: double.infinity,
                    decoration:  const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: size* 0.2),

                        Center(
                          child: Text(
                              "LYD", textAlign: TextAlign.center,
                              style: AppTextStyles.headline1(
                                context,color: AppColors.white )
                          ),
                        ),
                        SizedBox(height: size * 0.01),
                       Icon(Icons.local_hospital,color: AppColors.white,size:size*0.2 ,),
                        SizedBox(height: size* 0.09),

                        Center(
                          child: Container(
                            width: size* 0.83,
                            padding:  const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow:  const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              Center(
                                            child: Text(
                                                "WELCOME BACK", textAlign: TextAlign.center,
                                                style: AppTextStyles.subtitle(
                                                    context, )
                                            ),
                                          ),

                                          SizedBox(height: size * 0.01),

                                          // Subtitle
                                          Center(
                                            child: Text(
                                                "Fill Out the Information below In order to access your account.",
                                                textAlign: TextAlign.center,
                                                style: AppTextStyles.caption(
                                                    context,)
                                            ),
                                          ),
                                const SizedBox(height: 40),
                                CustomTextField(
                            hint: "Email",
                            icon: Icons.email,
                            controller: loginController.emailController,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            hint: "Password",
                            icon: Icons.lock,
                            isPassword: true,
                            controller: loginController.passwordController,
                          ),
                                          const SizedBox(height: 20),
                                Container(
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
                                                backgroundColor: AppColors.transparent,shadowColor: AppColors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () async {
                                                if (_formKeyLogin.currentState!.validate()) {
                                                  String email = loginController.emailController.text.trim();
                                                  String password = loginController.passwordController.text;

                                                  if (email.isEmpty ||
                                                      password.isEmpty) {
                                                    showCustomToast(context, "Please enter email and password",backgroundColor: AppColors.secondary);

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
                                                child:
                                             loginController.isLoading==true? const CircularProgressIndicator():
                                             Text("Sign In", style: AppTextStyles.body(context, color: AppColors.white))),),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width:size*0.3,
                                          child: const Divider(thickness: 0.4,color: AppColors.grey,)),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            "OR",
                                            textAlign: TextAlign.center,
                                            style: AppTextStyles.caption(
                                              context,)
                                        ),
                                      ),
                                      SizedBox(
                                        width:size*0.3,
                                        child: const Divider(
                                          thickness: 0.4,color: AppColors.grey,),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async{
                                    Get.toNamed('/registerPage');
                                    },
                                  child:  RichText(
                                    text: TextSpan(
                                      text: "Don't have an account? ",
                                      style: AppTextStyles.caption(context, color: AppColors.grey),
                                      children: [
                                        TextSpan(
                                          text: "Sign Up here",
                                          style: AppTextStyles.caption(
                                            context,
                                            color: AppColors.primary,fontWeight: FontWeight.bold
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                            },
                                        ),
                                      ],
                                    ),
                                  ),

                                ),
                                SizedBox(height: size*0.005,),
                                TextButton(
                                  onPressed: () async{
                                    Get.toNamed('/forgotPasswordWebScreen');
                                  },
                                  child:  RichText(
                                    text:
                                    TextSpan(
                                      text: "",
                                      style: AppTextStyles.body(context, color: AppColors.grey),
                                      children: [
                                        TextSpan(
                                            text: "Forgot Password",
                                          style: AppTextStyles.body(
                                              context,
                                              color: AppColors.primary,fontWeight: FontWeight.bold
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                            },
                                        ),
                                      ],
                                    ),
                                  ),

                                ),

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}