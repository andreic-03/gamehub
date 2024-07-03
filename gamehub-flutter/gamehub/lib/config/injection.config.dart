// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i5;
import 'package:flutter/material.dart' as _i8;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../interceptors/auth_interceptor.dart' as _i4;
import '../navigation/app_drawer.dart' as _i7;
import '../network/network_module.dart' as _i10;
import '../providers/auth_provider.dart' as _i3;
import '../screens/login/login_view_model.dart' as _i9;
import '../services/auth_service.dart' as _i6;

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
  gh.factory<_i7.AppDrawer>(() => _i7.AppDrawer(
        key: gh<_i8.Key>(),
        onSelectScreen: gh<_i7.ScreenSelectionCallback>(),
        authService: gh<_i6.AuthService>(),
        authProvider: gh<_i3.AuthProvider>(),
      ));
  gh.factory<_i9.LoginViewModel>(() => _i9.LoginViewModel(
        gh<_i6.AuthService>(),
        gh<_i3.AuthProvider>(),
      ));
  return getIt;
}

class _$NetworkModule extends _i10.NetworkModule {}
