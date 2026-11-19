import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';

class VerifyOtpPassword extends StatefulWidget {
  const VerifyOtpPassword({super.key});

  @override
  State<VerifyOtpPassword> createState() => _VerifyOtpPasswordState();
}

class _VerifyOtpPasswordState extends State<VerifyOtpPassword> {
  final loginController = Get.put(LoginController());
  final _formKeyForgotPassword = GlobalKey<FormState>();
  bool isLoading = false;

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
  late final List<TextEditingController> _otpControllers = [
    otp1,
    otp2,
    otp3,
    otp4,
  ];
  late final List<FocusNode> _otpFocusNodes = List.generate(
    4,
    (_) => FocusNode(),
  );

  void _clearOtpBoxes() {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    FocusScope.of(context).requestFocus(_otpFocusNodes.first);
  }

  // Handles both normal single-digit typing and a full code landing at once
  // (SMS autofill suggestion or a paste) by distributing digits across boxes
  // instead of letting a single field's maxLength silently truncate it.
  void _handleOtpChanged(int index, String rawValue) {
    final digits = rawValue.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length <= 1) {
      _otpControllers[index].value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
      if (digits.length == 1) {
        if (index < _otpControllers.length - 1) {
          FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
        } else {
          _otpFocusNodes[index].unfocus();
        }
      }
      return;
    }

    // Multiple digits arrived at once: fill every box from the start so an
    // autofilled/pasted code is distributed correctly instead of truncated.
    for (var i = 0; i < _otpControllers.length; i++) {
      final digit = i < digits.length ? digits[i] : '';
      _otpControllers[i].value = TextEditingValue(
        text: digit,
        selection: TextSelection.collapsed(offset: digit.length),
      );
    }
    final lastIndex = (digits.length - 1).clamp(0, _otpControllers.length - 1);
    if (lastIndex < _otpControllers.length - 1) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[lastIndex + 1]);
    } else {
      _otpFocusNodes[lastIndex].unfocus();
    }
  }

  Widget otpBox(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppColors.primaryLight2,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppColors.primaryLight2,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
        ),
        onChanged: (value) => _handleOtpChanged(index, value),
      ),
    );
  }

  Future<void> verifyOtp() async {
    setState(() {
      isLoading = true;
    });

    final String otp = otp1.text + otp2.text + otp3.text + otp4.text;

    await loginController.verifyOtpPassword(
      Api.userInfo.read('otpMail') ?? "",
      otp,
      context,
    );

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
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
                        otpBox(0),
                        otpBox(1),
                        otpBox(2),
                        otpBox(3),
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
                        _clearOtpBoxes();
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
