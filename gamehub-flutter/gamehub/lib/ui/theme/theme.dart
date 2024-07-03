import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.green,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.light(),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.lightGreen,
  ),
);

final ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.green,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: ColorScheme.dark(),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green,
  ),
);