import 'package:flutter/material.dart';
import 'package:gamehub/providers/auth_provider.dart';
import 'package:gamehub/screens/profile/profile_content.dart';
import '../navigation/app_bottom_navigation_bar.dart';
import '../navigation/app_drawer.dart';
import '../config/injection.dart';
import '../services/auth_service.dart';
import 'home/home_content.dart';

class BaseScreen extends StatefulWidget {
  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    ProfileContent(),
    // SettingsContent(),
    // InfoContent(),
  ];

  final List<String> _titles = [
    'GameHub - Home',
    'GameHub - Profile',
    // 'GameHub - Settings',
    // 'GameHub - Info',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      drawer: AppDrawer(
          onSelectScreen: _onItemTapped,
          authService: getIt<AuthService>(),
          authProvider: getIt<AuthProvider>(),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}