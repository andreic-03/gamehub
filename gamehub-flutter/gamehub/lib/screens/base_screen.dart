import 'package:flutter/material.dart';
import 'package:gamehub/core/viewmodels/auth_view_model.dart';
import 'package:gamehub/screens/map_screen/map_content.dart';
import 'package:gamehub/screens/profile/profile_content.dart';
import '../navigation/app_bottom_navigation_bar.dart';
import '../navigation/app_drawer.dart';
import '../config/injection.dart';
import '../services/auth/auth_service.dart';
import 'home/home_content.dart';

class BaseScreen extends StatefulWidget {
  final Widget? floatingActionButton;

  const BaseScreen({
    Key? key,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  BaseScreenState createState() => BaseScreenState();
}

class BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;
  final GlobalKey<HomeContentState> _homeContentKey = GlobalKey<HomeContentState>();

  late final List<Widget> _screens;

  final List<String> _titles = [
    'GameHub - Home',
    'GameHub - Map',
    'GameHub - Profile',
    // 'GameHub - Settings',
    // 'GameHub - Info',
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContent(key: _homeContentKey),
      MapContent(),
      ProfileContent(),
      // SettingsContent(),
      // InfoContent(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Method to refresh home content
  Future<void> refreshHomeContent() async {
    if (_homeContentKey.currentState != null) {
      await _homeContentKey.currentState!.refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the required services directly
    final authService = getIt<AuthService>();
    final authViewModel = getIt<AuthViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      drawer: AppDrawer(
          onSelectScreen: _onItemTapped,
          authService: authService,
          authViewModel: authViewModel,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0 ? widget.floatingActionButton : null,
    );
  }
}