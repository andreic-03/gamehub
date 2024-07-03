
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../interceptors/auth_interceptor.dart';
import '../providers/auth_provider.dart';
import 'network_constants.dart';

final getIt = GetIt.instance;

@module
abstract class NetworkModule {

  @lazySingleton
  Map<String, String> get headers => NetworkConstants.headers;

  @singleton
  AuthProvider get authProvider => AuthProvider();

  @singleton
  AuthInterceptor get authInterceptor => AuthInterceptor();

  @lazySingleton
  Dio get dio => Dio()
    ..interceptors.add(authInterceptor)
    ..options.headers = headers;

  @Named("baseURL")
  String get baseURL => NetworkConstants.baseURL;
}