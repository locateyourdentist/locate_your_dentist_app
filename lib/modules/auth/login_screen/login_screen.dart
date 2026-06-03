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
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
  }
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
        // body:  Form(
        //   key: _formKeyLogin,
        //   child: LayoutBuilder(
        //       builder: (context, constraints) {
        //         return SingleChildScrollView(
        //           child: ConstrainedBox(
        //             constraints: BoxConstraints(minHeight: constraints.maxHeight),
        //             child: Container(
        //             //width: double.infinity,
        //             //height: double.infinity,
        //             decoration:  const BoxDecoration(
        //               gradient: LinearGradient(
        //                 colors: [AppColors.primary, AppColors.secondary],
        //                 begin: Alignment.topLeft,
        //                 end: Alignment.bottomRight,
        //               ),
        //             ),
        //             child:
        //             // Column(
        //             //   crossAxisAlignment: CrossAxisAlignment.center,
        //             //   mainAxisAlignment: MainAxisAlignment.start,
        //             //   children: [
        //             //     SizedBox(height: size* 0.2),
        //             //
        //             //     Center(
        //             //       child: Text(
        //             //           "LYD", textAlign: TextAlign.center,
        //             //           style: AppTextStyles.headline1(
        //             //             context,color: AppColors.white )
        //             //       ),
        //             //     ),
        //             //     SizedBox(height: size * 0.01),
        //             //    Icon(Icons.local_hospital,color: AppColors.white,size:size*0.2 ,),
        //             //     SizedBox(height: size* 0.09),
        //             //
        //             //     Center(
        //             //       child: Container(
        //             //         width: size* 0.83,
        //             //         padding:  const EdgeInsets.all(20),
        //             //         decoration: BoxDecoration(
        //             //           color: Colors.white,
        //             //           borderRadius: BorderRadius.circular(16),
        //             //           boxShadow:  const [
        //             //             BoxShadow(
        //             //               color: Colors.black26,
        //             //               blurRadius: 10,
        //             //               offset: Offset(0, 5),
        //             //             )
        //             //           ],
        //             //         ),
        //             //         child: Column(
        //             //           mainAxisSize: MainAxisSize.min,
        //             //           children: [
        //             //           Center(
        //             //                         child: Text(
        //             //                             "WELCOME BACK", textAlign: TextAlign.center,
        //             //                             style: AppTextStyles.subtitle(
        //             //                                 context, )
        //             //                         ),
        //             //                       ),
        //             //
        //             //                       SizedBox(height: size * 0.01),
        //             //
        //             //                       // Subtitle
        //             //                       Center(
        //             //                         child: Text(
        //             //                             "Fill Out the Information below In order to access your account.",
        //             //                             textAlign: TextAlign.center,
        //             //                             style: AppTextStyles.caption(
        //             //                                 context,)
        //             //                         ),
        //             //                       ),
        //             //             const SizedBox(height: 40),
        //             //             CustomTextField(
        //             //         hint: "Email",
        //             //         icon: Icons.email,
        //             //         controller: loginController.emailController,
        //             //       ),
        //             //       const SizedBox(height: 16),
        //             //       CustomTextField(
        //             //         hint: "Password",
        //             //         icon: Icons.lock,
        //             //         isPassword: true,
        //             //         controller: loginController.passwordController,
        //             //       ),
        //             //                       const SizedBox(height: 20),
        //             //             Container(
        //             //               width: size,
        //             //               decoration: BoxDecoration(
        //             //                 gradient: const LinearGradient(
        //             //                   colors: [AppColors.primary, AppColors.secondary],
        //             //                   begin: Alignment.topLeft,
        //             //                   end: Alignment.bottomRight,
        //             //                 ),
        //             //                 borderRadius: BorderRadius.circular(12),
        //             //               ),
        //             //                         child: ElevatedButton(
        //             //                           style: ElevatedButton.styleFrom(
        //             //                             backgroundColor: AppColors.transparent,shadowColor: AppColors.transparent,
        //             //                             shape: RoundedRectangleBorder(
        //             //                               borderRadius: BorderRadius.circular(12),
        //             //                             ),
        //             //                           ),
        //             //                           onPressed: () async {
        //             //                             if (_formKeyLogin.currentState!.validate()) {
        //             //                               String email = loginController.emailController.text.trim();
        //             //                               String password = loginController.passwordController.text;
        //             //
        //             //                               if (email.isEmpty ||
        //             //                                   password.isEmpty) {
        //             //                                 showCustomToast(context, "Please enter email and password",backgroundColor: AppColors.secondary);
        //             //
        //             //                                 return;
        //             //                               }
        //             //                               await loginController.login(
        //             //                                   loginController.emailController.text.toString(),
        //             //                                   loginController.passwordController.text.toString(),platform,context);
        //             //                              loginController.emailController.clear();
        //             //                              loginController.passwordController.clear();
        //             //                             } else {
        //             //                               showCustomToast(context,  "Invalid email or password",backgroundColor: AppColors.secondary);
        //             //                             }
        //             //                           },
        //             //                             child:
        //             //                          loginController.isLoading==true? const CircularProgressIndicator():
        //             //                          Text("Sign In", style: AppTextStyles.body(context, color: AppColors.white))),),
        //             //             Padding(
        //             //               padding: const EdgeInsets.all(5.0),
        //             //               child: Row(
        //             //                 children: [
        //             //                   SizedBox(
        //             //                       width:size*0.3,
        //             //                       child: const Divider(thickness: 0.4,color: AppColors.grey,)),
        //             //                   Padding(
        //             //                     padding: const EdgeInsets.all(8.0),
        //             //                     child: Text(
        //             //                         "OR",
        //             //                         textAlign: TextAlign.center,
        //             //                         style: AppTextStyles.caption(
        //             //                           context,)
        //             //                     ),
        //             //                   ),
        //             //                   SizedBox(
        //             //                     width:size*0.3,
        //             //                     child: const Divider(
        //             //                       thickness: 0.4,color: AppColors.grey,),
        //             //                   ),
        //             //                 ],
        //             //               ),
        //             //             ),
        //             //             TextButton(
        //             //               onPressed: () async{
        //             //                 Get.toNamed('/registerPage');
        //             //                 },
        //             //               child:  RichText(
        //             //                 text: TextSpan(
        //             //                   text: "Don't have an account? ",
        //             //                   style: AppTextStyles.caption(context, color: AppColors.grey),
        //             //                   children: [
        //             //                     TextSpan(
        //             //                       text: "Sign Up here",
        //             //                       style: AppTextStyles.caption(
        //             //                         context,
        //             //                         color: AppColors.primary,fontWeight: FontWeight.bold
        //             //                       ),
        //             //                       recognizer: TapGestureRecognizer()
        //             //                         ..onTap = () {
        //             //                         },
        //             //                     ),
        //             //                   ],
        //             //                 ),
        //             //               ),
        //             //
        //             //             ),
        //             //             SizedBox(height: size*0.005,),
        //             //             TextButton(
        //             //               onPressed: () async{
        //             //                 Get.toNamed('/forgotPasswordPage');
        //             //               },
        //             //               child:  RichText(
        //             //                 text:
        //             //                 TextSpan(
        //             //                   text: "",
        //             //                   style: AppTextStyles.body(context, color: AppColors.grey),
        //             //                   children: [
        //             //                     TextSpan(
        //             //                         text: "Forgot Password",
        //             //                       style: AppTextStyles.body(
        //             //                           context,
        //             //                           color: AppColors.primary,fontWeight: FontWeight.bold
        //             //                       ),
        //             //                       recognizer: TapGestureRecognizer()
        //             //                         ..onTap = () {
        //             //                         },
        //             //                     ),
        //             //                   ],
        //             //                 ),
        //             //               ),
        //             //
        //             //             ),
        //             //
        //             //           ],
        //             //         ),
        //             //       ),
        //             //     ),
        //             //   ],
        //             // ),
        //             Center(
        //               child: SingleChildScrollView(
        //                 child: Container(
        //                   constraints: const BoxConstraints(
        //                     maxWidth: 480,
        //                   ),
        //                   margin: const EdgeInsets.all(20),
        //                   child: Card(
        //                     elevation: 25,
        //                     shadowColor: Colors.black26,
        //                     shape: RoundedRectangleBorder(
        //                       borderRadius: BorderRadius.circular(30),
        //                     ),
        //                     child: Padding(
        //                       padding: const EdgeInsets.symmetric(
        //                         horizontal: 30,
        //                         vertical: 40,
        //                       ),
        //                       child: Column(
        //                         mainAxisSize: MainAxisSize.min,
        //                         children: [
        //
        //                           /// LOGO
        //                           Container(
        //                             height: 90,
        //                             width: 90,
        //                             decoration: BoxDecoration(
        //                               shape: BoxShape.circle,
        //                               gradient: const LinearGradient(
        //                                 colors: [
        //                                   AppColors.primary,
        //                                   AppColors.secondary,
        //                                 ],
        //                               ),
        //                               boxShadow: [
        //                                 BoxShadow(
        //                                   color: AppColors.primary.withOpacity(.3),
        //                                   blurRadius: 20,
        //                                 )
        //                               ],
        //                             ),
        //                             child: const Icon(
        //                               Icons.local_hospital,
        //                               color: Colors.white,
        //                               size: 45,
        //                             ),
        //                           ),
        //
        //                           const SizedBox(height: 25),
        //
        //                           Text(
        //                             "Welcome Back 👋",
        //                             style: AppTextStyles.subtitle(
        //                               context,
        //                             ).copyWith(
        //                               fontWeight: FontWeight.bold,
        //                               fontSize: 28,
        //                             ),
        //                           ),
        //
        //                           const SizedBox(height: 8),
        //
        //                           Text(
        //                             "Login to continue using Locate Your Dentist",
        //                             textAlign: TextAlign.center,
        //                             style: AppTextStyles.caption(
        //                               context,
        //                               color: AppColors.grey,
        //                             ),
        //                           ),
        //
        //                           const SizedBox(height: 35),
        //
        //                           CustomTextField(
        //                             hint: "Email Address",
        //                             icon: Icons.email_outlined,
        //                             controller: loginController.emailController,
        //                           ),
        //
        //                           const SizedBox(height: 18),
        //
        //                           CustomTextField(
        //                             hint: "Password",
        //                             icon: Icons.lock_outline,
        //                             isPassword: true,
        //                             controller: loginController.passwordController,
        //                           ),
        //
        //                           const SizedBox(height: 12),
        //
        //                           Align(
        //                             alignment: Alignment.centerRight,
        //                             child: TextButton(
        //                               onPressed: () {
        //                                 Get.toNamed('/forgotPasswordPage');
        //                               },
        //                               child: Text(
        //                                 "Forgot Password?",
        //                                 style: AppTextStyles.caption(
        //                                   context,
        //                                   color: AppColors.primary,
        //                                 ),
        //                               ),
        //                             ),
        //                           ),
        //
        //                           const SizedBox(height: 15),
        //
        //                           Container(
        //                             width: double.infinity,
        //                             height: 55,
        //                             decoration: BoxDecoration(
        //                               borderRadius: BorderRadius.circular(15),
        //                               gradient: const LinearGradient(
        //                                 colors: [
        //                                   AppColors.primary,
        //                                   AppColors.secondary,
        //                                 ],
        //                               ),
        //                             ),
        //                             child: ElevatedButton(
        //                               style: ElevatedButton.styleFrom(
        //                                 backgroundColor: Colors.transparent,
        //                                 shadowColor: Colors.transparent,
        //                                 shape: RoundedRectangleBorder(
        //                                   borderRadius: BorderRadius.circular(15),
        //                                 ),
        //                               ),
        //                               onPressed: () async {
        //
        //                                 if (_formKeyLogin.currentState!.validate()) {
        //
        //                                   String email = loginController
        //                                       .emailController.text
        //                                       .trim();
        //
        //                                   String password = loginController
        //                                       .passwordController.text;
        //
        //                                   if (email.isEmpty ||
        //                                       password.isEmpty) {
        //
        //                                     showCustomToast(
        //                                       context,
        //                                       "Please enter email and password",
        //                                       backgroundColor:
        //                                       AppColors.secondary,
        //                                     );
        //
        //                                     return;
        //                                   }
        //
        //                                   await loginController.login(
        //                                     loginController.emailController.text,
        //                                     loginController.passwordController.text,
        //                                     platform,
        //                                     context,
        //                                   );
        //
        //                                   loginController.emailController.clear();
        //                                   loginController.passwordController.clear();
        //                                 }
        //                               },
        //                               child: loginController.isLoading
        //                                   ? const CircularProgressIndicator(
        //                                 color: Colors.white,
        //                               )
        //                                   : Text(
        //                                 "SIGN IN",
        //                                 style: AppTextStyles.body(
        //                                   context,
        //                                   color: Colors.white,
        //                                 ),
        //                               ),
        //                             ),
        //                           ),
        //
        //                           const SizedBox(height: 25),
        //
        //                           Row(
        //                             children: [
        //                               const Expanded(child: Divider()),
        //                               Padding(
        //                                 padding: const EdgeInsets.symmetric(
        //                                   horizontal: 15,
        //                                 ),
        //                                 child: Text(
        //                                   "OR",
        //                                   style: AppTextStyles.caption(
        //                                     context,
        //                                   ),
        //                                 ),
        //                               ),
        //                               const Expanded(child: Divider()),
        //                             ],
        //                           ),
        //
        //                           const SizedBox(height: 20),
        //
        //                           TextButton(
        //                             onPressed: () {
        //                               Get.toNamed('/registerPage');
        //                             },
        //                             child: RichText(
        //                               text: TextSpan(
        //                                 text: "Don't have an account? ",
        //                                 style: AppTextStyles.caption(
        //                                   context,
        //                                   color: AppColors.grey,
        //                                 ),
        //                                 children: [
        //                                   TextSpan(
        //                                     text: "Sign Up",
        //                                     style: AppTextStyles.caption(
        //                                       context,
        //                                       color: AppColors.primary,
        //                                     ).copyWith(
        //                                       fontWeight: FontWeight.bold,
        //                                     ),
        //                                   ),
        //                                 ],
        //                               ),
        //                             ),
        //                           ),
        //                         ],
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //             )
        //           ),
        //         ),
        //       );
        //     }
        //   ),
        // ),
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
                        AppColors.primary,AppColors.primary

                      ],
                    ),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 450,
                        ),
                        margin: const EdgeInsets.all(20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 15,
                              sigmaY: 15,
                            ),
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

                                        await loginController.login(
                                          email,
                                          password,
                                          platform,
                                          context,
                                        );

                                        loginController.emailController.clear();
                                        loginController.passwordController.clear();
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
                                        color: Colors.black,fontWeight: FontWeight.bold
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
            }
          ),
      ),
    );
  }
}