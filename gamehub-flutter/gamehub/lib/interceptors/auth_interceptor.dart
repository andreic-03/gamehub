import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../core/viewmodels/auth_view_model.dart';

class AuthInterceptor extends Interceptor {
  // Defer getting the AuthViewModel until it's needed to avoid circular dependencies
  AuthViewModel get _authViewModel => GetIt.instance<AuthViewModel>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Skip adding Authorization header for public endpoints
    if (!_isPublicEndpoint(options.path)) {
      final token = _authViewModel.token;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    super.onRequest(options, handler);
  }

  /// Check if the given path is a public endpoint that doesn't require authentication
  bool _isPublicEndpoint(String path) {
    final publicEndpoints = [
      '/auth/login',
      '/user/registration',
      '/auth/logout',
    ];
    
    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }
}
