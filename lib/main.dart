// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:locate_your_dentist/api/api.dart';
// import 'package:locate_your_dentist/api/firebase_options.dart';
// import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
// import 'package:locate_your_dentist/modules/auth/login_screen/service_locations.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'routes/app_pages.dart';
// import 'routes/app_routes.dart';
//
// /// Local Notifications
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// /// Android Notification Channel
// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel',
//   'High Importance Notifications',
//   description: 'Used for important notifications',
//   importance: Importance.high,
// );
//
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   debugPrint('Background message: ${message.messageId}');
// }
//
// Future<void> setupFCM() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//
//   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//     debugPrint('Notification permission granted');
//     String? token = await messaging.getToken();
//     print('token$token');
//     if (token != null) {
//       Api.userInfo.write('fcmToken',token);
//       debugPrint('FCM TOKEN: $token');
//     }
//   } else {
//     debugPrint('Notification permission denied');
//   }
//   FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//     Api.userInfo.write('fcmToken',newToken);
//     debugPrint('FCM TOKEN REFRESHED: $newToken');
//   });
// }
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await GetStorage.init();
//   // await Firebase.initializeApp(
//   //   options: DefaultFirebaseOptions.currentPlatform,
//   // );
//   if (Firebase.apps.isEmpty) {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     print("Firebase initialized successfully.");
//   } else {
//     Firebase.app();
//     print("Firebase app already exists, skipping initialization.");
//   }
//   FirebaseMessaging.onBackgroundMessage(
//       firebaseMessagingBackgroundHandler);
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   const AndroidInitializationSettings androidInit =
//   AndroidInitializationSettings('@mipmap/ic_launcher');
//
//   const InitializationSettings initSettings =
//   InitializationSettings(android: androidInit);
//
//   await flutterLocalNotificationsPlugin.initialize(initSettings);
//
//   // Setup FCM (TOKEN + PERMISSION)
//   await setupFCM();
//
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
//
//     if (notification != null && android != null) {
//       flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             channel.id,
//             channel.name,
//             channelDescription: channel.description,
//             importance: Importance.high,
//             priority: Priority.high,
//             icon: '@mipmap/ic_launcher',
//           ),
//         ),
//       );
//     }
//   });
//
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     debugPrint('Notification clicked');
//     Get.toNamed(AppRoutes.notificationPage);
//   });
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   bool isShowOnboard = prefs.getBool('isShowOnboard') ?? false;
//   final loginController=Get.put(LoginController());
//
//   final position = await LocationService.getCurrentLocation();
//   if (position != null) {
//     loginController.latitude = position.latitude;
//     loginController.longitude = position.longitude;
//     print('latt${loginController.latitude}long${loginController.longitude}');
//     debugPrint('User location: Lat ${position.latitude}, Lng ${position.longitude}');
//   }
//   runApp(MyApp(isShowOnboard: isShowOnboard));
// }
//
// class MyApp extends StatefulWidget {
//   final bool isShowOnboard;
//
//   const MyApp({super.key, required this.isShowOnboard});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       handleInitialLink();
//     });
//   }
//
//   void handleInitialLink() {
//     // This works for Android/iOS cold start
//     final initialRoute = PlatformDispatcher.instance.defaultRouteName;
//     if (initialRoute != "/") {
//       Uri uri = Uri.parse(initialRoute);
//       print("Deep link received: $uri");
//       if (uri.path == "/lyd/user/verify_password") {
//         String? token = uri.queryParameters['token'];
//         Get.toNamed('/verifyPasswordPage', arguments: {'token': token});
//       }
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Locate Your Dentist',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       getPages: AppPages.page,
//       initialRoute:
//       widget.isShowOnboard ? AppRoutes.splashScreen : AppRoutes.onBoardScreen,
//     );
//   }
// }
//}

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:locate_your_dentist/common_widgets/platform_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/api.dart';
import 'api/firebase_options.dart';
import 'modules/auth/login_screen/login_controller.dart';
import 'modules/auth/login_screen/service_locations.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'utills/constants.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Used for important notifications',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Background message received: ${message.messageId}");
}

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    String? token = await messaging.getToken(
      vapidKey: kIsWeb ? AppConstants.webFireBaseVAPID_KEY : null,
    );
    if (token != null) Api.userInfo.write('fcmToken', token);
    print("FCM Token: $token");
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    Api.userInfo.write('fcmToken', newToken);
    print("FCM Token refreshed: $newToken");
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // print("Firebase initialized successfully");
  //
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
  InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
  //await setupFCM();
  final loginController = Get.put(LoginController());
  final position = await LocationService.getCurrentLocation();
  if (position != null) {
    loginController.latitude = position.latitude;
    loginController.longitude = position.longitude;
    print('User location: Lat ${position.latitude}, Lng ${position.longitude}');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isShowOnboard = prefs.getBool('isShowOnboard') ?? false;

  runApp(MyApp(isShowOnboard: isShowOnboard));
}

class MyApp extends StatefulWidget {
  final bool isShowOnboard;

  const MyApp({super.key, required this.isShowOnboard});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleInitialLink();
    });
  }

  void handleInitialLink() {
    final initialRoute = PlatformDispatcher.instance.defaultRouteName;
    if (initialRoute != "/") {
      Uri uri = Uri.parse(initialRoute);
      if (uri.path == "/lyd/user/verify_password") {
        String? token = uri.queryParameters['token'];
        Get.toNamed('/verifyPasswordPage', arguments: {'token': token});
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Locate Your Dentist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      /// ✅ ADD THIS (VERY IMPORTANT)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate, // 🔥 REQUIRED
      ],

      /// ✅ ADD THIS
      supportedLocales: const [
        Locale('en'),
      ],

      getPages: AppPages.page,
      initialRoute: PlatformHelper.platform == "Web"
          ? AppRoutes.splashScreen
          : (widget.isShowOnboard
          ? AppRoutes.splashScreen
          : AppRoutes.onBoardScreen),
    );
  }
}