import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/splash_screen/splash_contoller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  final splashController=Get.put(SplashController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: splashController.animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -20 * splashController.animation.value),
              child: Container(
                height: double.infinity,
                width: double.infinity,
                color: AppColors.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.white,
                      size: 150,
                    ),
                    const SizedBox(height: 10,),
                    Text('Locate your Dentist',style: AppTextStyles.subtitle(context,color: AppColors.white,),)
                  ],
                ),
              ),
            );
          },
        ),
      )
    );
  }
}
