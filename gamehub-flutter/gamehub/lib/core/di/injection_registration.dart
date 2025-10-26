import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../viewmodels/auth_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/base_view_model.dart';
import '../../services/auth/auth_service.dart';
import '../../services/game_post/game_post_service.dart';
import '../../services/user/user_service.dart';
import '../../screens/profile/profile_view_model.dart';
import '../../screens/my_game_posts/my_game_posts_view_model.dart';

/// Register all view models that are not automatically discovered by the injectable generator
@InjectableInit(
  initializerName: 'registerViewModels',
  preferRelativeImports: true,
  asExtension: true,
)
extension ViewModelRegistration on GetIt {
  void registerViewModels() {
    // Register our auth service and view model synchronously
    try {
      // Check if the AuthService is already registered
      if (!isRegistered<AuthService>()) {
        // If not, try to register it manually
        final dio = get<Dio>();
        final baseUrl = getAsync<String>(instanceName: 'baseURL');
        registerSingleton<AuthService>(AuthService(dio, baseUrl: baseUrl.toString()));
      }
      
      // Now register the AuthViewModel if not already registered
      if (!isRegistered<AuthViewModel>()) {
        final authService = get<AuthService>();
        registerSingleton<AuthViewModel>(AuthViewModel(authService));
      }
    } catch (e) {
      print('Error registering AuthViewModel: $e');
    }
    
    // Register HomeViewModel if not already registered
    try {
      if (!isRegistered<HomeViewModel>()) {
        registerFactory<HomeViewModel>(() => HomeViewModel(get<GamePostService>()));
      }
    } catch (e) {
      print('Error registering HomeViewModel: $e');
    }
    
    // Register ProfileViewModel if not already registered
    try {
      if (!isRegistered<ProfileViewModel>()) {
        registerFactory<ProfileViewModel>(() => ProfileViewModel(get<UserService>()));
      }
    } catch (e) {
      print('Error registering ProfileViewModel: $e');
    }
    
    // Register MyGamePostsViewModel if not already registered
    try {
      if (!isRegistered<MyGamePostsViewModel>()) {
        registerFactory<MyGamePostsViewModel>(() => MyGamePostsViewModel(get<GamePostService>()));
      }
    } catch (e) {
      print('Error registering MyGamePostsViewModel: $e');
    }
    
    // AppDrawer is now created directly in the UI where needed instead of through dependency injection
  }
} 