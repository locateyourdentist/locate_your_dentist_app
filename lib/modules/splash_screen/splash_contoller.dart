import 'dart:io';
import 'dart:ui';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:new_version_plus/new_version_plus.dart';
import '../../common_widgets/common-alertdialog.dart';
import '../auth/login_screen/service_locations.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  @override
  late AnimationController animationController;
  late Animation<double> animation;
  Future<void> checkForUpdate() async {
    try {
      final newVersion = NewVersionPlus(androidId: 'com.kst.e_attendance');
      final status = await newVersion.getVersionStatus();
      if (status == null) return;

      if (status.canUpdate) {
        print("Update available!");
        print("Current version: ${status.localVersion}");
        print("Store version: ${status.storeVersion}");
        showUpdateDialog("www.google.com");
      }
    } catch (e) {
      print("Version check failed: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
    animationController.repeat(reverse: true);
    //simulateLoading();
    //checkForUpdate();
  }

  @override
  void onReady() {
    super.onReady();
    checkToken();
  }

  void simulateLoading() async {
    await Future.delayed(const Duration(seconds: 3));
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      debugPrint(
        'User location: Lat ${position.latitude}, Lng ${position.longitude}',
      );
    }
  }

  void checkToken() async {
    String platform = kIsWeb
        ? "Web"
        : Platform.isAndroid
        ? "Android"
        : Platform.isIOS
        ? "iOS"
        : "Unknown";
    print("platform $platform");
    String? token = Api.userInfo.read('token');
    print('spalsh token$token');

    final requestedPath = Uri.parse(
      PlatformDispatcher.instance.defaultRouteName,
    ).path;

    // App Links (tapping a shared https://locateyourdentist.com/... link
    // with the app installed) land here the same way a browser deep link
    // does on web, so both platforms need to honor the requested page
    // instead of always falling through to the dashboard below.
    if (requestedPath.startsWith('/viewJobDetailWebPage/')) {
      final jobId = requestedPath.split('/').last;
      if (platform == "Web") {
        Get.offAllNamed(requestedPath);
      } else if (jobId.isNotEmpty) {
        Api.userInfo.write('selectJobId', jobId);
        Get.offAllNamed('/jobViewProfilePage');
      }
      return;
    }
    if (requestedPath.startsWith('/viewWebinarDetailWebPage/')) {
      final webinarId = requestedPath.split('/').last;
      if (platform == "Web") {
        Get.offAllNamed(requestedPath);
      } else if (webinarId.isNotEmpty) {
        Api.userInfo.write('webinarId', webinarId);
        Get.offAllNamed('/viewWebinarPage');
      }
      return;
    }
    if (platform == "Web" &&
        requestedPath.startsWith('/salePostDetailWebPage/')) {
      Get.offAllNamed(requestedPath);
      return;
    }
    // Play Store's privacy-policy checker (and any other anonymous visitor)
    // needs to land directly on the policy text without being bounced
    // through the login-gated flow below.
    if (platform == "Web" && requestedPath == '/viewLegalPage') {
      Get.offAllNamed(requestedPath);
      return;
    }

    if (token == null || token.isEmpty) {
      platform == "Web"
          ? Get.offAllNamed("/")
          : Get.offAllNamed("/patientDashboard");
    } else {
      String? userType = Api.userInfo.read('userType');
      platform == "Web"
          ? Get.offAllNamed('/${pageUserTypeWeb(userType ?? '')}')
          : Get.offAllNamed('/${pageUserType(userType ?? '')}');
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
