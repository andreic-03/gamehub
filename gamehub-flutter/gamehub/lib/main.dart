import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamehub/core/viewmodels/auth_view_model.dart';
import 'package:gamehub/screens/home/home_screen.dart';
import 'package:gamehub/screens/login/login_screen.dart';
import 'package:gamehub/screens/profile/profile_screen.dart';
import 'package:gamehub/config/injection.dart';
import 'package:get_it/get_it.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const GameHubApp());
}

class GameHubApp extends StatelessWidget {
  const GameHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = GetIt.I<AuthViewModel>();
    return ChangeNotifierProvider<AuthViewModel>(
      create: (_) => authViewModel,
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
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
      ),
    );
  }
}

