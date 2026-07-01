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
  final loginController = Get.put(LoginController());
  final _formKeyForgotPassword = GlobalKey<FormState>();
  bool isLoading = false;
  int resendCooldown = 60;
  late Timer timer;
  @override
  void dispose() {
    timer.cancel();
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
      body: jsonEncode({'email': Api.userInfo.read('otpMail') ?? ""}),
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
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      return true;
    }
    exit(0);
  }

  final otp1 = TextEditingController();
  final otp2 = TextEditingController();
  final otp3 = TextEditingController();
  final otp4 = TextEditingController();
  //final otp5 = TextEditingController();
  //final otp6 = TextEditingController();

  // bool isLoading = false;

  Widget otpBox(TextEditingController controller) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }

  Future<void> verifyOtp() async {
    setState(() {
      isLoading = true;
    });

    String otp =
        otp1.text +
        otp2.text +
        otp3.text +
        otp4.text +
        //otp5.text +
        //otp6.text;
        await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    print("OTP => $otp");
    Api.userInfo.read('otpMail');
    loginController.verifyOtpPassword(
      Api.userInfo.read('otpMail') ?? "",
      otp,
      context,
    );
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text("OTP Verified Successfully"),
    //   ),
    // );
  }

  @override
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onWillPopOTP,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.transparent,
          iconTheme: const IconThemeData(color: AppColors.white),
          automaticallyImplyLeading: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Get.back();
                // Navigator.pop(context);
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
                  child: Icon(Icons.arrow_back, color: AppColors.white),
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
                    SizedBox(height: size * 0.05),
                    Center(
                      child: Container(
                        width: size * 0.35,
                        height: size * 0.35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
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
                    SizedBox(height: size * 0.1),

                    Center(
                      child: Text(
                        'Verify OTP Password',
                        style: AppTextStyles.subtitle(
                          context,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: size * 0.02),
                    Text(
                      'Enter Your OTP',
                      textAlign: TextAlign.left,
                      style: AppTextStyles.caption(
                        context,
                        color: AppColors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: size * 0.1),

                    // OtpTextField(
                    //   numberOfFields: 4,
                    //   focusedBorderColor:AppColors.primary,
                    //   borderColor: AppColors.primary,
                    //   showFieldAsBox: true,
                    //   fieldWidth: size * 0.18,
                    //   fieldHeight: size * 0.18,
                    //   borderWidth: 3.0,
                    //   borderRadius: BorderRadius.circular(20),
                    //   onCodeChanged: (String code) {
                    //   },
                    //   onSubmit: (String verificationCode){
                    //     Api.userInfo.read('otpMail',);
                    //     loginController.verifyOtpPassword(Api.userInfo.read('otpMail')??"", verificationCode,context);
                    //
                    //   },
                    // ),
                    Text(
                      Api.userInfo.read('otpMail') ?? "",
                      //  widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        otpBox(otp1),
                        otpBox(otp2),
                        otpBox(otp3),
                        otpBox(otp4),
                        // otpBox(otp5),
                        // otpBox(otp6),
                      ],
                    ),

                    SizedBox(height: size * 0.13),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Verify",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    TextButton(
                      onPressed: () async {
                        await loginController.forgotPassword(
                          Api.userInfo.read('otpMail') ?? "",
                          context,
                        );
                      },
                      child: Text(
                        'Resend OTP',
                        style: AppTextStyles.caption(
                          context,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
