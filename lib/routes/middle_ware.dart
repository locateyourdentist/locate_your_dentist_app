import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';

class SuperAdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {

    String? userType = Api.userInfo.read('userType');

    if (userType != 'superAdmin') {
      return const RouteSettings(name: '/webLoginPage');
    }

    return null;
  }
}