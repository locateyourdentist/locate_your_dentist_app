import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:locate_your_dentist/firebase_options.dart';
import 'package:locate_your_dentist/common_widgets/platform_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/api.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'web_url_strategy_stub.dart'
if (dart.library.html) 'web_url_strategy.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Used for important notifications',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  print("Background message received: ${message.messageId}");
}
Future<String?> downloadAndSaveFile(
    String url,
    String fileName,
    ) async {
  if (kIsWeb) return null;

  try {
    final directory =
    await getApplicationDocumentsDirectory();

    final filePath =
        '${directory.path}/$fileName';

    final response =
    await http.get(Uri.parse(url));

    final file = File(filePath);

    await file.writeAsBytes(
      response.bodyBytes,
    );

    return file.path;
  } catch (e) {
    debugPrint(
      'downloadAndSaveFile error: $e',
    );
    return null;
  }
}
Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    try {
      if (Platform.isIOS) {
        final apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) {
          print("APNS token not available (e.g. iOS Simulator); "
              "skipping FCM token fetch.");
          return;
        }
      }

      final token = await messaging.getToken();
      print("FCM Token: $token");

      if (token != null) {
        Api.userInfo.write('fcmToken', token);
      }
    } catch (e) {
      print("Failed to fetch FCM token: $e");
    }
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    Api.userInfo.write('fcmToken', newToken);
    print("FCM Token refreshed: $newToken");
  });
}
Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await GetStorage.init();
  } catch (e) {
    debugPrint("GetStorage init failed: $e");
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }
// if(!kIsWeb) {
//   FirebaseMessaging.onBackgroundMessage(
//     firebaseMessagingBackgroundHandler,
//   );
//
//   await setupFCM();
// }
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    // Fire-and-forget: requestPermission() waits on the user answering the
    // OS notification-permission dialog, which has nothing to render behind
    // it before runApp() — awaiting here would block the entire app from
    // ever showing a first frame if that dialog goes unanswered.
    setupFCM();
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) async {

        print("MESSAGE RECEIVED");
        print(message.data);

        String imageUrl = message.data['image'] ?? '';

        BigPictureStyleInformation? bigPictureStyle;

        AndroidBitmap<Object>? largeIcon;


        if (!kIsWeb &&
            imageUrl.isNotEmpty) {
          try {
            final imagePath =
            await downloadAndSaveFile(
              imageUrl,
              'lyd-big_picture',
            );

            print("IMAGE SAVED = $imagePath");

            final file = File(imagePath!);

            print(
              "FILE EXISTS = ${await file.exists()}",
            );

            print(
              "FILE SIZE = ${await file.length()}",
            );

            largeIcon =
                FilePathAndroidBitmap(imagePath);

            bigPictureStyle =
                BigPictureStyleInformation(
                  FilePathAndroidBitmap(imagePath),
                  largeIcon: largeIcon,
                  contentTitle:
                  message.data['title'] ?? '',
                  summaryText:
                  message.data['body'] ?? '',
                  hideExpandedLargeIcon: false,
                );
          } catch (e) {
            print(
              "IMAGE DOWNLOAD ERROR = $e",
            );
          }
        }

        await flutterLocalNotificationsPlugin.show(
          id: DateTime.now()
              .millisecondsSinceEpoch ~/
              1000,
          title:
          message.data['title'] ??
              message.notification?.title ??
              '',
          body:
          message.data['body'] ??
              message.notification?.body ??
              '',
          notificationDetails:
          NotificationDetails(
            android:
            AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
              largeIcon: largeIcon,
              styleInformation:
              bigPictureStyle,
            ),
          ),
        );
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("NOTIFICATION CLICKED");
    });
  }
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings darwinInit =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // const InitializationSettings initSettings =
  // InitializationSettings(android: androidInit, iOS: darwinInit, macOS: darwinInit);
  // await flutterLocalNotificationsPlugin.initialize(
  //   settings: initSettings,
  // );
 // await flutterLocalNotificationsPlugin.initialize(initSettings);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isShowOnboard = prefs.getBool('isShowOnboard') ?? false;
  //setUrlStrategy(PathUrlStrategy()); // removes #
  configureUrlStrategy();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);


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