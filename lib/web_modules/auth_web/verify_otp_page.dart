import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class VerifyWebPasswordPage extends StatefulWidget {
  const VerifyWebPasswordPage({super.key});

  @override
  State<VerifyWebPasswordPage> createState() => _VerifyWebPasswordPageState();
}

class _VerifyWebPasswordPageState extends State<VerifyWebPasswordPage> {
  final loginController = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();
  bool isOtpSent = false;
  int _secondsRemaining = 60;
  bool _canResend = false;
  late Timer _timer;
  final TextEditingController otpController = TextEditingController();
  void _startTimer() {
    _secondsRemaining = 60;
    _canResend = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }@override
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
    _startTimer();
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  Widget _resendButton() {
    return TextButton(
      onPressed: _canResend
          ? () async {
        await loginController.forgotPassword(
            Api.userInfo.read('otpMail') ?? "", context);

        _startTimer();
      }
          : null,
      child: Text(
        _canResend
            ? "Resend OTP"
            : "Resend OTP  in 00:${_secondsRemaining.toString().padLeft(2, '0')}",
        style: AppTextStyles.caption(
          context,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ).copyWith(
          decoration: _canResend ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Form(
        key: _formKey,
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
            Center(
              child: Container(
                width: size> 800 ? 450 : size * 0.85,
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
                child: GetBuilder<LoginController>(
                  init: loginController,
                  builder: (_) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: ClipOval(
                            child: loginController.appLogoUrl != null
                                ? Image.network(
                              loginController.appLogoUrl!,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            )
                                : Container(
                              color: Colors.white.withOpacity(0.3),
                              child: const Icon(
                                Icons.medical_services,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                         "Verify OTP",
                          style: AppTextStyles.body(context),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          !isOtpSent
                              ? "Enter your received OTP"
                              : "Please enter the OTP sent to your email",
                          style: AppTextStyles.caption(
                              context, color: AppColors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                          OtpTextField(
                            numberOfFields: 4,
                            focusedBorderColor:AppColors.primary,
                            borderColor: AppColors.primary,
                            showFieldAsBox: true,
                            fieldWidth: size * 0.04,
                            fieldHeight: size * 0.04,
                            borderWidth: 3.0,
                            borderRadius: BorderRadius.circular(20),
                            onCodeChanged: (String code) {
                            },
                            onSubmit: (String verificationCode){
                              Api.userInfo.read('otpMail',);
                              loginController.verifyOtpPassword(Api.userInfo.read('otpMail')??"", verificationCode,context);
                              },
                          ),

                          const SizedBox(height: 10),
                          _resendButton(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}