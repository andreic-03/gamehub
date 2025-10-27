import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../core/viewmodels/auth_view_model.dart';
import '../core/viewmodels/home_view_model.dart';
import '../core/errors/api_error.dart';
import '../interceptors/auth_interceptor.dart';
import '../network/network_constants.dart';
import '../services/auth/auth_service.dart';
import '../services/game_post/game_post_service.dart';
import '../services/user/user_service.dart';
import '../services/game/game_service.dart';
import '../services/participants/participants_service.dart';
import '../screens/game_post/create_game_post_view_model.dart';
import '../screens/profile/profile_view_model.dart';
import '../screens/settings/settings_view_model.dart';
import '../screens/registration/registration_view_model.dart';
import '../screens/my_game_posts/my_game_posts_view_model.dart';
import '../localization/localization_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
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
  
  // Add global error handling interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) {
        // Log the error in detail
        print('--- API Error Interceptor ---');
        print('API Error Path: ${error.requestOptions.path}');
        print('API Error Type: ${error.type}');
        print('API Error Message: ${error.message}');
        
        if (error.response != null) {
          print('Response Status: ${error.response?.statusCode}');
          print('Response Data: ${error.response?.data}');
        }

        try {
          // Process all error responses
          if (error.response != null) {
            try {
              final apiError = ApiError.fromDioError(error);
              print('Parsed ApiError: ${apiError.code} - ${apiError.message}');
              
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  response: error.response,
                  type: error.type,
                  error: apiError,
                  message: apiError.userFriendlyMessage,
                ),
              );
            } catch (e) {
              print('Error in error intercept: $e');
            }
          }
        } catch (e) {
          print('Exception in error interceptor: $e');
        }
        
        return handler.next(error);
      },
    ),
  );
  
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

  getIt.registerLazySingleton<GameService>(() => GameService(
    getIt<Dio>(),
    baseUrl: NetworkConstants.baseURL,
  ));

  getIt.registerLazySingleton<ParticipantsService>(() => ParticipantsService(
    getIt<Dio>(),
    baseUrl: NetworkConstants.baseURL,
  ));

  // 4. Register View Models
  getIt.registerLazySingleton<AuthViewModel>(() => AuthViewModel(getIt<AuthService>()));
  getIt.registerFactory<HomeViewModel>(() => HomeViewModel(getIt<GamePostService>()));
  getIt.registerFactory<ProfileViewModel>(() => ProfileViewModel(getIt<UserService>()));
  getIt.registerFactory<CreateGamePostViewModel>(() => CreateGamePostViewModel(
        getIt<GamePostService>(),
        getIt<GameService>(),
      ));
  getIt.registerFactory<SettingsViewModel>(() => SettingsViewModel());
  getIt.registerFactory<RegistrationViewModel>(() => RegistrationViewModel(getIt<UserService>()));
  getIt.registerFactory<MyGamePostsViewModel>(() => MyGamePostsViewModel(getIt<GamePostService>()));

  // 5. Initialize localization service
  await LocalizationService.instance.initialize();

  // 6. Finally, register and setup interceptors (after all dependencies are ready)
  final authInterceptor = AuthInterceptor();
  getIt.registerLazySingleton<AuthInterceptor>(() => authInterceptor);
  dio.interceptors.add(authInterceptor);

  print('Dependency injection complete');
}
