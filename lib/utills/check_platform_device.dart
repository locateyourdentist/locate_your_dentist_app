import 'package:flutter/foundation.dart';

void checkPlatform() {
  if (kIsWeb) {
    print("Running on Web");
  } else {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        print("Running on Android");
        break;
      case TargetPlatform.iOS:
        print("Running on iOS");
        break;
      default:
        print("Running on another platform");
    }
  }
}
