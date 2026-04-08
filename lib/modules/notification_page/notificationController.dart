import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/model/notification_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:path_provider/path_provider.dart';
import '../../main.dart';

  class  NotificationController extends GetxController{
  List<NotificationModel>_notificationList=[];
  List<NotificationModel> get notificationList=>_notificationList;
  bool isLoading=true;
  final Api api = Api();
  String? unreadCount;
  List<File> notificationImage = [];
  List<AppImage> notificationFileImages = [];
  TextEditingController titleController=TextEditingController();
  TextEditingController messageController=TextEditingController();
  String? selectedUserType;
  String? selectedTitle;

  //final loginController=Get.put(LoginController());
  Future<void> createNotification(String userId,
      String userType,
      String title,
      String message,
      String state,
      String district,
      String city,
      String area,
      BuildContext context, {
        Uint8List? notificationImage1,
       // List<File>? notificationImage1,
      })async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _notificationList=[];
      final response = await api.createNotification( userId, userType, title, message, state, district, city, area,notificationImage1);
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        showSuccessDialog(context, title:"Success",message :"Notification Created Successfully", onOkPressed: () {});
        titleController.clear();
        messageController.clear();
        notificationImage.clear();
        notificationImage1=null;
        //loginController.update();
      } else {
        showCustomToast(context,  "notification error ,${data["message"] ?? "error"}",);
      }
    } catch (error) {
      print('notification list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
  Future<String?> downloadAndSaveImage(String url, String fileName) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';

      final response = await http.get(Uri.parse(url));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } catch (e) {
      debugPrint("Image download error: $e");
      return null;
    }
  }
  Future<void> showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification == null || android == null) return;
    BigPictureStyleInformation? bigPictureStyle;
    if (android.imageUrl != null && android.imageUrl!.isNotEmpty) {
      final String? imagePath = await downloadAndSaveImage(
        android.imageUrl!,
        'notification_image',
      );
      if (imagePath != null) {
        bigPictureStyle = BigPictureStyleInformation(
          FilePathAndroidBitmap(imagePath),
          contentTitle: notification.title,
          summaryText: notification.body,
        );
      }
    }
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: bigPictureStyle,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> getNotificationListAdmin( dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      _notificationList=[];
      final response = await api.getNotificationListAdmin();
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        List<dynamic> notifications = data["data"];
        unreadCount=data["unreadCount"].toString()??"0";
        print('notifi count$unreadCount');
        update();
        _notificationList = notifications.map((e) => NotificationModel.fromJson(e)).toList();
        if (_notificationList.isNotEmpty &&
            _notificationList.first.notificationImage != null &&
            _notificationList.first.notificationImage!.isNotEmpty) {

          final imageUrl = _notificationList.first.notificationImage!;

          notificationFileImages = imageUrl.map((u) => AppImage(url: AppConstants.baseUrl + u.replaceAll("\\", "/"))).toList();
        }
      } else {
        showCustomToast(
          context,
          "Notification Failed, ${data["message"] ?? "error"}",
        );
      }
    } catch (error) {
      print('notification list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> updateNotificationListAdmin( dynamic context) async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      Get.snackbar("No Internet", "Please check your connection");
      return;
    }
    isLoading=true;
    try {
      final response = await api.updateNotificationListAdmin();
      var data = jsonDecode(response.body);
      if ( data["status"].toString().toLowerCase() == "success") {
        print('update notification success' );

      } else {
     print('error update notification');
      }
    } catch (error) {
      print('notification list admin error $error');
    } finally {
      isLoading = false;
      update();
    }
  }
}