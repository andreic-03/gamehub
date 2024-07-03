import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../providers/auth_provider.dart';

class AuthInterceptor extends Interceptor {
  final AuthProvider _authProvider = GetIt.I<AuthProvider>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.path.contains('/auth/login')) {
      final token = _authProvider.token;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    super.onRequest(options, handler);
  }
}
