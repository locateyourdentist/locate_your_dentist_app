import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/model/serviceModel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/utills/constants.dart';

class ServiceController extends GetxController{
  var isLoading = false;
  List<ServiceModel>_serviceList=[];
  List<ServiceModel> get serviceList=>_serviceList;
  List<ServiceModel>_serviceDetails=[];
  List<ServiceModel> get serviceDetails=>_serviceDetails;
  List<dynamic>_privacyDetails=[];
  List<dynamic> get PrivacyDetails=>_privacyDetails;
  List<Map<String, dynamic>> privacyData = [];
  final loginController=Get.put(LoginController());
  final Api api = Api();
  String? selectedServiceId;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  String? selectServiceId;
  List<File>? serviceImage=[];
  bool isTitleSidebarOpen = false;
  String? tempSelectedTitle;
  Future<void> getServiceListAdmin( String userId,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      print('hii');
      _serviceList=[];
      final response = await api.getServiceListAdmin( userId);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> services = data["data"];

        _serviceList = services.map((e) => ServiceModel.fromJson(e)).toList();

        // showCustomToast(context,  "Profile details fetched",);
      } else {
        //showCustomToast(context,  "can not get service error,${data["message"] ?? "error"}",);
        //Get.snackbar("Login Failed", data["message"] ?? "error");
      }
    } catch (error) {
      print('job list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<List<Map<String, dynamic>>> getPrivacyPolicyDetails(
      String category,
      BuildContext context,
      ) async {

    var connection = await Connectivity().checkConnectivity();

    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return [];
    }

    try {
      final response = await api.getPrivacyPolicyDetails(category);
      var data = jsonDecode(response.body);

      if (data["status"] == "success") {
        List<dynamic> services = data["data"] ?? [];

        if (services.isNotEmpty && services[0]["data"] != null) {
          return List<Map<String, dynamic>>.from(services[0]["data"]);
        }
      }

      return [];

    } catch (e) {
      print("privacy error: $e");
      return [];
    }
  }
  // Future<void> getPrivacyPolicyDetails(String category,dynamic context) async {
  //   var connection = await Connectivity().checkConnectivity();
  //
  //   if (connection == ConnectivityResult.none) {
  //     Get.snackbar("No Internet", "Please check your connection");
  //     return;
  //   }
  //
  //   isLoading = true;
  //   update();
  //
  //   try {
  //     _privacyDetails = [];
  //
  //     final response = await api.getPrivacyPolicyDetails( category,);
  //     var data = jsonDecode(response.body);
  //
  //     if (data["status"]?.toString().toLowerCase() == "success") {
  //       List<dynamic> services = data["data"] ?? [];
  //
  //       if (services.isNotEmpty) {
  //         var rawData = services[0]["data"];
  //         if (rawData is List) {
  //           privacyData = List<Map<String, dynamic>>.from(rawData);
  //         } else if (rawData is String) {
  //           privacyData = List<Map<String, dynamic>>.from(
  //             jsonDecode(rawData),
  //           );
  //         } else {
  //           privacyData = [];
  //         }
  //       } else {
  //         privacyData = [];
  //       }
  //     } else {
  //       privacyData = [];
  //     }
  //   } catch (error) {
  //     print('privacy content error: $error');
  //   } finally {
  //     isLoading = false;
  //     update();
  //   }
  // }
  // Future<void> getServiceDetailAdmin( String serviceId,dynamic context) async {
  //   var connection = await Connectivity().checkConnectivity();
  //   if (connection == ConnectivityResult.none) {
  //     Get.snackbar("No Internet", "Please check your connection");
  //     return;
  //   }
  //   isLoading=true;
  //   try {
  //     print('hii');
  //     _serviceDetails=[];
  //     final response = await api.getServiceDetailAdmin( serviceId);
  //     var data = jsonDecode(response.body);
  //     if ( data["status"].toString().toLowerCase() == "success") {
  //       List<dynamic> services = data["data"];
  //       //_serviceDetails = services.map((e) => ServiceModel.fromJson(e)).toList();
  //       _serviceDetails = services.map((e) {
  //         return ServiceModel.fromJson(e as Map<String, dynamic>);
  //       }).toList();
  //       titleController.text = _serviceDetails.first.serviceTitle?.toString() ?? "";
  //       selectedServiceId=_serviceDetails.first.serviceId.toString()??"";
  //       descriptionController.text=_serviceDetails.first.serviceDescription?.toString()??"";
  //       costController.text=_serviceDetails.first.serviceCost?.toString()??"";
  //       final service = ServiceModel.fromJson(data["data"]);
  //       _serviceDetails=[service];
  //       final images = service.image ?? [];
  //       loginController.serviceFileImages = images
  //           .map((u) => AppImage(url: AppConstants.baseUrl + u.replaceAll("\\", "/")))
  //           .toList();
  //     } else {
  //       showCustomToast(context,  "can not get service error,${data["message"] ?? "error"}",);
  //       //Get.snackbar("Login Failed", data["message"] ?? "error");
  //     }
  //   } catch (error) {
  //     print('service list admin error $error');
  //   } finally {
  //     isLoading = false;
  //     update();
  //   }
  // }
  Future<void> getServiceDetailAdmin(String serviceId, dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    try {
      isLoading = true;
      print('Getting service details...');
      _serviceDetails = [];
      final response = await api.getServiceDetailAdmin(serviceId);
      var data = jsonDecode(response.body);
      if (data["status"].toString().toLowerCase() == "success") {
        List<dynamic> list = data["data"];
        if (list.isEmpty) {
          showCustomToast(context, "No details found");
          return;
        }
        final service = ServiceModel.fromJson(list[0]);
        _serviceDetails = [service];

        titleController.text = service.serviceTitle ?? "";
        descriptionController.text = service.serviceDescription ?? "";
        costController.text = service.serviceCost ?? "";
        selectedServiceId = service.serviceId.toString();

        final images = service.image ?? [];
        // loginController.serviceFileImages = images.map((u) {
        //   //final finalUrl = "${AppConstants.baseUrl}${u.replaceAll("\\", "/")}";
        //   final finalUrl = "${u.replaceAll("\\", "/")}";
        //   print("Mapped image URL → $finalUrl");
        //   return AppImage(url: finalUrl);
        // }).toList();
        loginController.serviceFileImages = images.map((u) {
          final finalUrl = u.replaceAll("\\", "/");
          return AppImage2(url: finalUrl);
        }).toList();
        loginController.update();

        // final service = ServiceModel.fromJson(list[0]);
        // _serviceDetails = [service];
        // titleController.text = service.serviceTitle ?? "";
        // descriptionController.text = service.serviceDescription ?? "";
        // costController.text = service.serviceCost ?? "";
        // selectedServiceId = service.serviceId.toString();
        // final images = service.image ?? [];
        // loginController.serviceFileImages = images
        //     .map((u) {
        //   final finalUrl = "${AppConstants.baseUrl}${u.replaceAll("\\", "/")}";
        //   print("Mapped image URL → $finalUrl");
        //   return AppImage(url: finalUrl);
        // })
        //     .toList();
        //
        // loginController.update();
      } else {
        showCustomToast(context,
            "Cannot get service: ${data["message"] ?? "error"}");
      }
    } catch (error) {
      print('service list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> deactivateService( String serviceId,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _serviceList=[];
      final response = await api.deactivateService( serviceId);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {

        showCustomToast(context,  "deleted successfully",);
      } else {
        showCustomToast(context,  "service not deleted,${data["message"] ?? "error"}",);
        //Get.snackbar("Login Failed", data["message"] ?? "error");
      }
    } catch (error) {
      print('job list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> createServiceAdmin(String serviceId,String userId,String userType, String serviceTitle,String serviceDescription,
      String serviceCost,serviceImage, List<String>? serviceImageUrl,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.createServiceAdmin( serviceId, userId, userType,  serviceTitle, serviceDescription, serviceCost, serviceImage,serviceImageUrl);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context, title:"Success",message :"Services added Successfully", onOkPressed: () {
        });
        titleController.clear();
        descriptionController.clear();
        costController.clear();
        serviceImage?.clear();
        serviceDetails.clear();
        loginController.serviceFileImages.clear();
        getServiceListAdmin(Api.userInfo.read('userId')??"", context);
      } else {
        showCustomToast(context,  "service post Failed, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('job application error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
}