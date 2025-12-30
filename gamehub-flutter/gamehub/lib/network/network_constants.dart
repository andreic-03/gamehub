import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class NetworkConstants {
  /// Change this to your computer's IP address when using WiFi debugging
  /// Find your IP by running 'ipconfig' on Windows or 'ifconfig' on Mac/Linux
  /// Example: "http://192.168.1.14:8080/api"
  static const String wifiDebuggingIP = "http://192.168.1.14:8080/api";
  
  /// Set to true when debugging on a physical device via WiFi
  static const bool isPhysicalDevice = true;
  
  static String get baseURL {
    if (kIsWeb) {
      // Web uses the host machine directly
      return "http://localhost:8080/api";
    }

    // Use Flutter's target platform to avoid importing dart:io on web
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Use WiFi IP if on physical device, otherwise use emulator loopback
        return isPhysicalDevice ? wifiDebuggingIP : "http://10.0.2.2:8080/api";
      default:
        // iOS simulator, desktop platforms
        return "http://localhost:8080/api";
    }
  }

  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // WebSocket Configuration
  static const String wsEndpointWithApi = '/api/chat.sendMessage';
  static const String wsEndpointWithoutApi = '/chat.sendMessage';

  // STOMP Configuration
  static const String stompTopicPrefix = '/topic/gamePost/';
  static const String stompSendDestination = '/app/chat.sendMessage';
  static const String stompAcceptVersion = '1.1,1.0';
  static const String stompHeartBeat = '10000,10000';

  // Reconnection Configuration
  static const int maxReconnectAttempts = 5;
  static const int initialReconnectDelayMs = 1000;
  static const int maxReconnectDelayMs = 30000;

  // HTTP Timeout Configuration
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const List<int> retryableStatusCodes = [408, 500, 502, 503, 504];
}