# Preserve Flutter Plugin and MethodChannel interfaces
-keep class io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class io.flutter.embedding.engine.plugins.FlutterPlugin$FlutterPluginBinding { *; }
-keep class io.flutter.plugin.common.MethodChannel$* { *; }

# If you use get_storage or packages requiring JNI
-keep class com.intentfilter.androidnative.proxy.* { *; }

# If you happen to use ffmpeg_kit (known to conflict with Firebase channels)
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class org.ffmpeg.** { *; }
-dontwarn com.arthenica.ffmpegkit.**
-dontwarn org.ffmpeg.**