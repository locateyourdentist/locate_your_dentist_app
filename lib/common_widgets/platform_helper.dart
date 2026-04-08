// import 'package:flutter/foundation.dart';
// import 'dart:io' show Platform;
//
// class PlatformHelper {
//   static String get platform {
//     if (kIsWeb) return "Web";
//
//     if (Platform.isAndroid) return "Android";
//     if (Platform.isIOS) return "iOS";
//     if (Platform.isWindows) return "Windows";
//     if (Platform.isMacOS) return "MacOS";
//     if (Platform.isLinux) return "Linux";
//
//     return "Unknown";
//   }
// }
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class PlatformHelper {
  static String get platform {
    if (kIsWeb) return "Web";

    try {
      if (Platform.isAndroid) return "Android";
      if (Platform.isIOS) return "iOS";
      if (Platform.isWindows) return "Windows";
      if (Platform.isMacOS) return "MacOS";
      if (Platform.isLinux) return "Linux";
    } catch (e) {
      // Platform not available (like Web)
      return "Unknown";
    }

    return "Unknown";
  }
}