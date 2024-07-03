import 'dart:io';

class NetworkConstants {
  static const baseURL = "http://10.0.2.2:8080/api";

  static const Map<String, String> headers = {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
  };
}