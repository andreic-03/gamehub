import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../navigation/app_drawer.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: false,
  ignoreUnregisteredTypes: [Key, ScreenSelectionCallback],
)
void configureDependencies() => init(getIt);
