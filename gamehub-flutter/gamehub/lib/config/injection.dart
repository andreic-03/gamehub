import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../core/viewmodels/auth_view_model.dart';
import '../core/viewmodels/home_view_model.dart';
import '../interceptors/auth_interceptor.dart';
import '../network/network_constants.dart';
import '../services/auth/auth_service.dart';
import '../services/game_post/game_post_service.dart';
import '../services/user/user_service.dart';
import '../screens/profile/profile_view_model.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  // Clear any existing registrations to avoid conflicts
  if (getIt.isRegistered<AuthViewModel>()) {
    getIt.unregister<AuthViewModel>();
  }

  // 1. Register Network Constants
  getIt.registerLazySingleton<Map<String, String>>(() => NetworkConstants.headers);
  getIt.registerLazySingleton<String>(() => NetworkConstants.baseURL, instanceName: 'baseURL');

  // 2. Create Dio instance without interceptors initially
  final dio = Dio()
    ..options.headers = NetworkConstants.headers;
  getIt.registerLazySingleton<Dio>(() => dio);

  // 3. Register Services
  getIt.registerLazySingleton<AuthService>(() => AuthService(
    getIt<Dio>(),
    baseUrl: NetworkConstants.baseURL,
  ));
  
  getIt.registerLazySingleton<GamePostService>(() => GamePostService(
    getIt<Dio>(),
    baseUrl: NetworkConstants.baseURL,
  ));
  
  getIt.registerLazySingleton<UserService>(() => UserService(
    getIt<Dio>(),
    baseUrl: NetworkConstants.baseURL,
  ));

  // 4. Register View Models
  getIt.registerLazySingleton<AuthViewModel>(() => AuthViewModel(getIt<AuthService>()));
  getIt.registerFactory<HomeViewModel>(() => HomeViewModel(getIt<GamePostService>()));
  getIt.registerFactory<ProfileViewModel>(() => ProfileViewModel(getIt<UserService>()));

  // 5. Finally, register and setup interceptors (after all dependencies are ready)
  final authInterceptor = AuthInterceptor();
  getIt.registerLazySingleton<AuthInterceptor>(() => authInterceptor);
  dio.interceptors.add(authInterceptor);

  print('Dependency injection complete');
}
