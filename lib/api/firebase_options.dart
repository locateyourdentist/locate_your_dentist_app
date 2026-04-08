import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

/// Firebase configuration for all platforms.
/// Replace the placeholders below with your actual Firebase credentials.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Android Firebase configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyXXXXXX-YOUR_ANDROID_API_KEY-XXXXXX",
    appId: "1:123456789012:android:abcdef123456",
    messagingSenderId: "123456789012",
    projectId: "locateyourdentist-5c2ca",
    storageBucket: "locateyourdentist-5c2ca.appspot.com",
  );

  // iOS Firebase configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyXXXXXX-YOUR_IOS_API_KEY-XXXXXX",
    appId: "1:123456789012:ios:abcdef123456",
    messagingSenderId: "123456789012",
    projectId: "locateyourdentist-5c2ca",
    storageBucket: "locateyourdentist-5c2ca.appspot.com",
    iosClientId: "YOUR_IOS_CLIENT_ID.apps.googleusercontent.com",
    iosBundleId: "com.catchytechnologies.LYD.locateYourDentist",
  );

  // macOS Firebase configuration
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyXXXXXX-YOUR_MACOS_API_KEY-XXXXXX",
    appId: "1:123456789012:macos:abcdef123456",
    messagingSenderId: "123456789012",
    projectId: "locateyourdentist-5c2ca",
    storageBucket: "locateyourdentist-5c2ca.appspot.com",
  );

  // Web Firebase configuration
  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyD0lcg8qsEarpbjiWJkUODu53EF7lT9ajU",
      authDomain: "locateyourdentist-5c2ca.firebaseapp.com",
      projectId: "locateyourdentist-5c2ca",
      storageBucket: "locateyourdentist-5c2ca.firebasestorage.app",
      messagingSenderId: "831601657278",
      appId: "1:831601657278:web:d39cd0bca707c6b917a5ef",
      measurementId: "G-4L5K3C4TWL"
  );
  // Windows and Linux fallback (use Android config)
  static const FirebaseOptions windows = android;
  static const FirebaseOptions linux = android;
}