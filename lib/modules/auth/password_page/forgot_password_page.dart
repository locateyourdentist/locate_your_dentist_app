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
  final loginController=Get.put(LoginController());
  final _formKeyForgotPassword = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return  Scaffold(
      appBar: AppBar(
        centerTitle: true,backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text('Forgot Password',style: AppTextStyles.subtitle(context,color: AppColors.black),),
        automaticallyImplyLeading: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
               Get.back();
               },
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
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
                  // Image.asset(
                  //   'assets/images/logo.jpg',
                  //   width: double.infinity,
                  //   height: size * 0.25,
                  //   fit: BoxFit.cover,
                  // ),
                  // SizedBox(height: size * 0.18),
                  // Center(child: Text('Forgot Password',style: AppTextStyles.subtitle(context,color: AppColors.primary),)),
                  SizedBox(height: size * 0.1),
                  Text('Enter your Email Address',textAlign:TextAlign.left,style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                  SizedBox(height: size * 0.09),

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
                    child:   Container(
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
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.transparent,shadowColor: AppColors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKeyForgotPassword.currentState!.validate()) {
                            Api.userInfo.write('otpMail', loginController.emailController.text);
                            await loginController.forgotPassword(loginController.emailController.text,context);
                          }
                        },
                        child: Text('Send OTP',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.white),),

                      ),
                    ),
                  ),
                  SizedBox(height: size*0.06,),

              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        thickness: 0.4,
                        color: AppColors.grey,
                      ),
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
                      child: Divider(
                        thickness: 0.4,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
                  SizedBox(height: size*0.12,),
                  Center(
                    child:   Container(
                      width: size,
                      decoration: BoxDecoration(color: AppColors.transparent,
                        // gradient: const LinearGradient(
                        //   colors: [AppColors.white, AppColors.white],
                        //   begin: Alignment.topLeft,
                        //   end: Alignment.bottomRight,
                        // ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          Get.toNamed('/registerPage');

                        },
                        child: Text('Sign Up',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.black),),

                      ),
                    ),
                  ),


                ],
              ),
            ),
          ),
        ),
      ),
      //bottomNavigationBar: CommonBottomNavigation(currentIndex: 0),
    );
  }
}
