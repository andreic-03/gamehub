// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i5;
import 'package:flutter/material.dart' as _i11;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../interceptors/auth_interceptor.dart' as _i4;
import '../navigation/app_drawer.dart' as _i10;
import '../network/network_module.dart' as _i13;
import '../providers/auth_provider.dart' as _i3;
import '../screens/login/login_view_model.dart' as _i9;
import '../screens/profile/profile_view_model.dart' as _i12;
import '../services/auth/auth_service.dart' as _i6;
import '../services/game_post/game_post_service.dart' as _i8;
import '../services/user/user_service.dart' as _i7;

// initializes the registration of main-scope dependencies inside of GetIt
_i1.GetIt init(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final networkModule = _$NetworkModule();
  gh.singleton<_i3.AuthProvider>(() => networkModule.authProvider);
  gh.singleton<_i4.AuthInterceptor>(() => networkModule.authInterceptor);
  gh.lazySingleton<Map<String, String>>(() => networkModule.headers);
  gh.lazySingleton<_i5.Dio>(() => networkModule.dio);
  gh.factory<String>(
    () => networkModule.baseURL,
    instanceName: 'baseURL',
  );
  gh.factory<_i6.AuthService>(() => _i6.AuthService(
        gh<_i5.Dio>(),
        baseUrl: gh<String>(instanceName: 'baseURL'),
      ));
  gh.factory<_i7.UserService>(() => _i7.UserService(
        gh<_i5.Dio>(),
        baseUrl: gh<String>(instanceName: 'baseURL'),
      ));
  gh.factory<_i8.GamePostService>(() => _i8.GamePostService(
        gh<_i5.Dio>(),
        baseUrl: gh<String>(instanceName: 'baseURL'),
      ));
  gh.factory<_i9.LoginViewModel>(() => _i9.LoginViewModel(
        gh<_i6.AuthService>(),
        gh<_i3.AuthProvider>(),
      ));
  gh.factory<_i10.AppDrawer>(() => _i10.AppDrawer(
        key: gh<_i11.Key>(),
        onSelectScreen: gh<_i10.ScreenSelectionCallback>(),
        authService: gh<_i6.AuthService>(),
        authProvider: gh<_i3.AuthProvider>(),
      ));
  gh.factory<_i12.ProfileViewModel>(
      () => _i12.ProfileViewModel(gh<_i7.UserService>()));
  return getIt;
}

class _$NetworkModule extends _i13.NetworkModule {}
