import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gamehub/providers/auth_provider.dart';
import 'package:injectable/injectable.dart';
import '../../models/auth_request_model.dart';
import '../../models/error/error_response.dart';
import '../../services/auth_service.dart';

@injectable
class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;
  final AuthProvider _authProvider;

  LoginViewModel(this._authService, this._authProvider);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authRequest = AuthRequestModel(
        identifier: username,
        password: password,
      );

      final authResponse = await _authService.login(authRequest);

      _authProvider.setToken(authResponse.accessToken);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      if (e.response != null && e.response!.data != null) {
        final errorResponse = ErrorResponse.fromJson(e.response!.data);
        _errorMessage = errorResponse.message;
      } else {
        _errorMessage = 'An error occurred. Please try again.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }
}
