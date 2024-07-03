
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';

class AuthProvider with ChangeNotifier {
  String? _token;

  String? get token => _token;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }

  void clearToken() {
    _token = null;
    notifyListeners();
  }
}