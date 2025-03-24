import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../core/viewmodels/auth_view_model.dart';

class AuthInterceptor extends Interceptor {
  // Defer getting the AuthViewModel until it's needed to avoid circular dependencies
  AuthViewModel get _authViewModel => GetIt.instance<AuthViewModel>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.path.contains('/auth/login')) {
      final token = _authViewModel.token;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    super.onRequest(options, handler);
  }
}
