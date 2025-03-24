// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i4;
import 'package:flutter/material.dart' as _i10;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../core/viewmodels/auth_view_model.dart' as _i8;
import '../core/viewmodels/home_view_model.dart' as _i11;
import '../interceptors/auth_interceptor.dart' as _i3;
import '../navigation/app_drawer.dart' as _i9;
import '../network/network_module.dart' as _i13;
import '../screens/profile/profile_view_model.dart' as _i12;
import '../services/auth/auth_service.dart' as _i5;
import '../services/game_post/game_post_service.dart' as _i6;
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
  gh.singleton<_i3.AuthInterceptor>(() => networkModule.authInterceptor);
  gh.lazySingleton<Map<String, String>>(() => networkModule.headers);
  gh.lazySingleton<_i4.Dio>(() => networkModule.dio);
  gh.factory<String>(
    () => networkModule.baseURL,
    instanceName: 'baseURL',
  );
  gh.factory<_i5.AuthService>(() => _i5.AuthService(
        gh<_i4.Dio>(),
        baseUrl: gh<String>(instanceName: 'baseURL'),
      ));
  gh.factory<_i6.GamePostService>(() => _i6.GamePostService(
        gh<_i4.Dio>(),
        baseUrl: gh<String>(instanceName: 'baseURL'),
      ));
  gh.factory<_i7.UserService>(() => _i7.UserService(
        gh<_i4.Dio>(),
        baseUrl: gh<String>(instanceName: 'baseURL'),
      ));
  gh.factory<_i8.AuthViewModel>(() => _i8.AuthViewModel(gh<_i5.AuthService>()));
  gh.factory<_i9.AppDrawer>(() => _i9.AppDrawer(
        key: gh<_i10.Key>(),
        onSelectScreen: gh<_i9.ScreenSelectionCallback>(),
        authService: gh<_i5.AuthService>(),
        authViewModel: gh<_i8.AuthViewModel>(),
      ));
  gh.factory<_i11.HomeViewModel>(
      () => _i11.HomeViewModel(gh<_i6.GamePostService>()));
  gh.factory<_i12.ProfileViewModel>(
      () => _i12.ProfileViewModel(gh<_i7.UserService>()));
  return getIt;
}

class _$NetworkModule extends _i13.NetworkModule {}
