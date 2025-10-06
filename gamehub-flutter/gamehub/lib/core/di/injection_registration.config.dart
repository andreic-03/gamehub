// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter/material.dart' as _i409;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../interceptors/auth_interceptor.dart' as _i1059;
import '../../navigation/app_drawer.dart' as _i175;
import '../../network/network_module.dart' as _i786;
import '../../screens/profile/profile_view_model.dart' as _i970;
import '../../services/auth/auth_service.dart' as _i756;
import '../../services/game/game_service.dart' as _i890;
import '../../services/game_post/game_post_service.dart' as _i624;
import '../../services/user/user_service.dart' as _i640;
import '../viewmodels/auth_view_model.dart' as _i928;
import '../viewmodels/home_view_model.dart' as _i1014;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt registerViewModels({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.singleton<_i1059.AuthInterceptor>(() => networkModule.authInterceptor);
    gh.lazySingleton<Map<String, String>>(() => networkModule.headers);
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.factory<String>(() => networkModule.baseURL, instanceName: 'baseURL');
    gh.factory<_i756.AuthService>(
      () => _i756.AuthService(
        gh<_i361.Dio>(),
        baseUrl: gh<String>(instanceName: 'baseURL'),
      ),
    );
    gh.factory<_i890.GameService>(
      () => _i890.GameService(
        gh<_i361.Dio>(),
        baseUrl: gh<String>(instanceName: 'baseURL'),
      ),
    );
    gh.factory<_i624.GamePostService>(
      () => _i624.GamePostService(
        gh<_i361.Dio>(),
        baseUrl: gh<String>(instanceName: 'baseURL'),
      ),
    );
    gh.factory<_i640.UserService>(
      () => _i640.UserService(
        gh<_i361.Dio>(),
        baseUrl: gh<String>(instanceName: 'baseURL'),
      ),
    );
    gh.factory<_i928.AuthViewModel>(
      () => _i928.AuthViewModel(gh<_i756.AuthService>()),
    );
    gh.factory<_i175.AppDrawer>(
      () => _i175.AppDrawer(
        key: gh<_i409.Key>(),
        onSelectScreen: gh<_i175.ScreenSelectionCallback>(),
        authService: gh<_i756.AuthService>(),
        authViewModel: gh<_i928.AuthViewModel>(),
      ),
    );
    gh.factory<_i1014.HomeViewModel>(
      () => _i1014.HomeViewModel(gh<_i624.GamePostService>()),
    );
    gh.factory<_i970.ProfileViewModel>(
      () => _i970.ProfileViewModel(gh<_i640.UserService>()),
    );
    return this;
  }
}

class _$NetworkModule extends _i786.NetworkModule {}
