import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:locate_your_dentist/common_widgets/platform_helper.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/api.dart';
import 'api/firebase_options.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
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

// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   print("Background message received: ${message.messageId}");
// }
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
    // String? token = await messaging.getToken(
    //  vapidKey: kIsWeb ? AppConstants.webFireBaseVAPID_KEY : null,
    // );
    //
    // print('kkftoken$token');
    // if (token != null) Api.userInfo.write('fcmToken', token);
    // print("FCM Token: $token");
    String? token;

    if (kIsWeb) {
      token = await messaging.getToken(
        vapidKey: AppConstants.webFireBaseVAPID_KEY,
      );
    } else {
      token = await messaging.getToken();
    }

    print("FCM Token: $token");

    if (token != null) {
      Api.userInfo.write('fcmToken', token);
    }

  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    Api.userInfo.write('fcmToken', newToken);
    print("FCM Token refreshed: $newToken");
  });
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  //
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  //
  // FirebaseMessaging.onBackgroundMessage(
  //   firebaseMessagingBackgroundHandler,
  // );

  //await setupFCM();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
  InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      getPages: AppPages.page,
      initialRoute: PlatformHelper.platform == "Web" ? AppRoutes.splashScreen
          : (widget.isShowOnboard ? AppRoutes.splashScreen : AppRoutes.onBoardScreen),
    );
  }
}