import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class NetworkConstants {
  static String get baseURL {
    if (kIsWeb) {
      // Web uses the host machine directly
      return "http://localhost:8080/api";
    }

    // Use Flutter's target platform to avoid importing dart:io on web
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator loopback to host
        return "http://10.0.2.2:8080/api";
      default:
        // iOS simulator, desktop platforms
        return "http://localhost:8080/api";
    }
  }

  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}