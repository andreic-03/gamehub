import 'package:flutter/material.dart';
import 'package:gamehub/core/viewmodels/auth_view_model.dart';
import 'package:gamehub/screens/home/home_screen.dart';
import 'package:gamehub/screens/login/login_screen.dart';
import 'package:gamehub/screens/profile/profile_screen.dart';
import 'package:gamehub/config/injection.dart';
import 'package:get_it/get_it.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const GameHubApp());
}

class GameHubApp extends StatelessWidget {
  const GameHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = GetIt.I<AuthViewModel>();
    return ListenableBuilder(
      listenable: authViewModel,
      builder: (context, _) {
        return MaterialApp(
          title: 'GameHub',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
          home: authViewModel.isAuthenticated ? HomeScreen() : LoginScreen(),
          routes: {
            '/login': (context) => LoginScreen(),
            '/home': (context) => HomeScreen(),
            '/profile': (context) => ProfileScreen(),
          },
        );
      },
    );
  }
}
