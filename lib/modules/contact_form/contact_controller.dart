import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/model/contact_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';


class ContactController extends GetxController{
  final Api api = Api();
  bool isLoading=false;
  TextEditingController doctorNameController=TextEditingController();
  TextEditingController contactClinicNameController=TextEditingController();
  TextEditingController clinicAddressController=TextEditingController();
  TextEditingController contactDetailsController=TextEditingController();
  final loginController=Get.put(LoginController());
  List<ContactModel>_senderContactLists=[];
  List<ContactModel> get senderContactLists=>_senderContactLists;
  List<ContactModel>_filterContactLists=[];
  List<ContactModel> get filterContactLists=>_filterContactLists;
  List<ContactModel>_receiverContactLists=[];
  List<ContactModel> get receiverContactLists=>_receiverContactLists;
  List<AppImage> editImages = [];

  Future<void> postContactDetail(String senderUserId,String receiverUserId,String email,String mobileNumber,String clinicName,String doctorName, String materialDescription,String state,String district,String city,contactImage1,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.postContactDetail( senderUserId, receiverUserId, email, mobileNumber, clinicName, doctorName,  materialDescription, state, district, city,contactImage1);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        if (!context.mounted) return;

        showSuccessDialog(context, title:"Success",message :"Contact Form submitted Successfully", onOkPressed: () {
        });
        contactClinicNameController.clear();
        doctorNameController.clear();
        contactDetailsController.clear();
        clinicAddressController.clear();
        loginController.contactImages.clear();
      } else {
        showCustomToast(context,  "Job post Failed, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('job application error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> postPublicContactDetail(String email,String mobileNumber,String name, String description,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.postPublicContactDetail(   email, mobileNumber, name,  description);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        if (!context.mounted) return;

        showSuccessDialog(context, title:"Success",message :"Contact Form submitted Successfully", onOkPressed: () {
        });
        contactClinicNameController.clear();
        doctorNameController.clear();
        contactDetailsController.clear();
      } else {
        showCustomToast(context,  "Job post Failed, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('job application error $error');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> postFilterResults(String receiverUserId,String senderUserId,String state,String district,String city,String status, String search,String fromDate,String toDate,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _filterContactLists=[];
      final response = await api.contactFilterSearch( receiverUserId, senderUserId, state, district, city, status,  search, fromDate, toDate,);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> jobs = data["data"];
        _filterContactLists = jobs.map((e) => ContactModel.fromJson(e)).toList();
        update();
      } else {
        showCustomToast(context,  "Job post Failed, ${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('job application error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<void> getSenderContactFormLists(String senderId,String fromDate,String toDate,String search,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _senderContactLists=[];
      final response = await api.getSenderContactLists( senderId, fromDate, toDate, search,);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
       // List<dynamic> jobs = data["data"];
       // _senderContactLists = jobs.map((e) => ContactModel.fromJson(e)).toList();
        List<dynamic> jobs = data["data"];
        _senderContactLists =
            jobs.map((e) => ContactModel.fromJson(e)).toList();
        // if (jobs.isNotEmpty) {
        //   List images = jobs[0]["contactImage"] ?? [];
        //   editImages = images
        //       .map((u) => AppImage(url: u.toString().replaceAll("\\", "/")))
        //       .toList();
        // }

        _senderContactLists =
            jobs.map((e) => ContactModel.fromJson(e)).toList();

        if (jobs.isNotEmpty) {
          List<dynamic> images = jobs[0]["contactImage"] ?? [];

          editImages = jobs
              .expand((job) => (job["contactImage"] as List? ?? []))
              .whereType<String>()
              .map((u) => AppImage(url: u.trim()))
              .toList();
        }
        update();
      } else {
        showCustomToast(context, "can not get sender list: ${data["message"]}");
      }
    } catch (e) {
      print('view Jobs  list error $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getReceiverContactFormLists(String receiverId,String fromDate,String toDate,String search,dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _receiverContactLists=[];
      final response = await api.getReceiverContactFormLists( receiverId, fromDate, toDate, search,);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        // List<dynamic> jobs = data["data"];
        // _senderContactLists = jobs.map((e) => ContactModel.fromJson(e)).toList();
        //  editImages = jobs.contactImage.map((u) => AppImage(url: u.replaceAll("\\", "/"))).toList();
        // print('dff$editImages');
        List<dynamic> jobs = data["data"];
        _receiverContactLists =
            jobs.map((e) => ContactModel.fromJson(e)).toList();
        if (jobs.isNotEmpty) {
          List images = jobs[0]["contactImage"] ?? [];
          editImages = images
              .map((u) => AppImage(url: u.toString().replaceAll("\\", "/")))
              .toList();
        }
        update();
        print('Images: $editImages');
      } else {
        showCustomToast(context, "can not get receiver list: ${data["message"]}");
      }
    } catch (e) {
      print('view Jobs  list error $e');
    } finally {
      isLoading = false;
      update();
    }
  }

}
