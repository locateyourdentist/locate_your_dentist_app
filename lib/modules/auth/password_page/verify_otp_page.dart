import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:http/http.dart' as http;

class VerifyOtpPassword extends StatefulWidget {
  const VerifyOtpPassword({super.key});

  @override
  State<VerifyOtpPassword> createState() => _VerifyOtpPasswordState();
}

class _VerifyOtpPasswordState extends State<VerifyOtpPassword> {
  final loginController=Get.put(LoginController());
  final _formKeyForgotPassword = GlobalKey<FormState>();
  bool isLoading = false;
  int resendCooldown = 60;
  late Timer timer;
  @override
  void dispose() {
    //otpController.dispose();
    timer?.cancel();
    super.dispose();
  }

  void startCooldown() {
    resendCooldown = 60;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (resendCooldown > 0) {
          resendCooldown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  Future<void> resendOtp() async {
    if (resendCooldown > 0) return;

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('https://your-api.com/resend-registration-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': Api.userInfo.read('otpMail')??""}),
    );

    final data = jsonDecode(response.body);
    setState(() => isLoading = false);

    if (data['status'] == 'success') {
      Get.snackbar('Success', data['message']);
      startCooldown();
    } else {
      Get.snackbar('Error', data['message']);
    }
  }
  DateTime? currentBackPressTime;

  Future<bool> _onWillPopOTP() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      //CommonDialog.showExitDialog(context);
     //  Get.toNamed('/patientDashboard');
      return true;
    }
    exit(0);
  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return  WillPopScope(
      onWillPop: _onWillPopOTP,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,backgroundColor: AppColors.white,
          iconTheme: const IconThemeData(color: AppColors.white),
         //title: Text('Verify OTP Password',style: AppTextStyles.subtitle(context,color: AppColors.black),),
          automaticallyImplyLeading: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
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

                     SizedBox(height: size * 0.15),
                    Center(child: Text('Verify OTP Password',style: AppTextStyles.subtitle(context,color: AppColors.black),)),
                    SizedBox(height: size * 0.02),
                    Text('Enter Your OTP',textAlign:TextAlign.left,style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.normal),),
                    SizedBox(height: size * 0.13),

                    OtpTextField(
                      numberOfFields: 4,
                      focusedBorderColor:AppColors.primary,
                      borderColor: AppColors.primary,
                      showFieldAsBox: true,
                      fieldWidth: size * 0.18,
                      fieldHeight: size * 0.18,
                      borderWidth: 3.0,
                      borderRadius: BorderRadius.circular(20),
                      onCodeChanged: (String code) {
                      },
                      onSubmit: (String verificationCode){
                        Api.userInfo.read('otpMail',);
                        loginController.verifyOtpPassword(Api.userInfo.read('otpMail')??"", verificationCode,context);

                      },
                    ),
                    const SizedBox(height: 0.1,),
                    TextButton(
                      onPressed: ()async{
                      await  loginController.forgotPassword(Api.userInfo.read('otpMail')??"",context);

                      },
                      child: Text(
                            'Resend OTP',
                        style: AppTextStyles.caption(context,color: AppColors.primary,fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isLoading) const CircularProgressIndicator(),

                  ],
                ),
              ),
            ),
          ),
        ),
        //bottomNavigationBar: CommonBottomNavigation(currentIndex: 0),
      ),
    );
  }
}
