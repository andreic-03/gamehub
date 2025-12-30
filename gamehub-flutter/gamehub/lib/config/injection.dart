import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../core/viewmodels/auth_view_model.dart';
import '../screens/home/home_view_model.dart';
import '../core/errors/api_error.dart';
import '../interceptors/auth_interceptor.dart';
import '../network/network_constants.dart';
import '../services/auth/auth_service.dart';
import '../services/game_post/game_post_service.dart';
import '../services/user/user_service.dart';
import '../services/game/game_service.dart';
import '../services/participants/participants_service.dart';
import '../services/messages/messages_service.dart';
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

  // 2. Create Dio instance with timeouts
  final dio = Dio(BaseOptions(
    headers: NetworkConstants.headers,
    connectTimeout: NetworkConstants.connectTimeout,
    receiveTimeout: NetworkConstants.receiveTimeout,
    sendTimeout: NetworkConstants.sendTimeout,
  ));

  // Add retry interceptor for transient failures
  dio.interceptors.add(_RetryInterceptor(dio));

  // Add global error handling interceptor
  dio.interceptors.add(_ErrorInterceptor());

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

  getIt.registerLazySingleton<MessagesService>(() => MessagesService(
    getIt<Dio>(),
    baseUrl: NetworkConstants.baseURL,
  ));

  // 4. Register View Models
  getIt.registerLazySingleton<AuthViewModel>(() => AuthViewModel(getIt<AuthService>(), getIt<UserService>()));
  getIt.registerFactory<HomeViewModel>(() => HomeViewModel(getIt<GamePostService>()));
  getIt.registerFactory<ProfileViewModel>(() => ProfileViewModel(getIt<UserService>()));
  getIt.registerFactory<SettingsViewModel>(() => SettingsViewModel());
  getIt.registerFactory<RegistrationViewModel>(() => RegistrationViewModel(getIt<UserService>()));
  getIt.registerFactory<MyGamePostsViewModel>(() => MyGamePostsViewModel(getIt<GamePostService>()));

  // 5. Initialize localization service
  await LocalizationService.instance.initialize();

  // 6. Finally, register and setup auth interceptor (after all dependencies are ready)
  final authInterceptor = AuthInterceptor();
  getIt.registerLazySingleton<AuthInterceptor>(() => authInterceptor);
  dio.interceptors.add(authInterceptor);

  debugPrint('Dependency injection complete');
}

/// Retry interceptor for handling transient failures with exponential backoff
class _RetryInterceptor extends Interceptor {
  final Dio _dio;

  _RetryInterceptor(this._dio);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    // Check if we should retry
    if (_shouldRetry(err) && retryCount < NetworkConstants.maxRetryAttempts) {
      // Exponential backoff delay
      final delay = NetworkConstants.retryDelay * (retryCount + 1);
      await Future.delayed(delay);

      // Update retry count
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      debugPrint('Retrying request (${retryCount + 1}/${NetworkConstants.maxRetryAttempts}): ${err.requestOptions.path}');

      try {
        // Retry the request
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // If retry also fails, continue with error handling
        if (e is DioException) {
          return handler.next(e);
        }
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on timeout errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on specific HTTP status codes
    final statusCode = err.response?.statusCode;
    if (statusCode != null && NetworkConstants.retryableStatusCodes.contains(statusCode)) {
      return true;
    }

    return false;
  }
}

/// Error interceptor for parsing API errors
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    // Only log in debug mode
    if (kDebugMode) {
      debugPrint('API Error: ${error.requestOptions.path} - ${error.type}');
      if (error.response != null) {
        debugPrint('Status: ${error.response?.statusCode}');
      }
    }

    try {
      if (error.response != null) {
        try {
          final apiError = ApiError.fromDioError(error);

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
          if (kDebugMode) {
            debugPrint('Error parsing API error: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Exception in error interceptor: $e');
      }
    }

    return handler.next(error);
  }
}
