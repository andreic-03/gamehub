import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamehub/core/viewmodels/auth_view_model.dart';
import 'package:gamehub/screens/map_screen/map_content.dart';
import 'package:gamehub/screens/profile/profile_content.dart';
import '../navigation/app_bottom_navigation_bar.dart';
import '../navigation/app_drawer.dart';
import '../config/injection.dart';
import '../services/auth/auth_service.dart';
import '../localization/localized_text.dart';
import '../localization/localization_service.dart';
import 'home/home_screen.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens;

  final List<String> _titleKeys = [
    'base_screen.home_title',
    'base_screen.map_title',
    'base_screen.profile_title'
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContent(key: _homeContentKey),
      MapContent(),
      ProfileContent()
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
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
          onSelectScreen: _onItemTapped,
          authService: authService,
          authViewModel: authViewModel,
      ),
      body: Stack(
        children: [
          _screens[_selectedIndex],
          // Floating hamburger menu button
          Positioned(
            top: 50,
            left: 16,
            child: FloatingActionButton.small(
              heroTag: "base_screen_menu_button",
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Icon(Icons.menu),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0 ? widget.floatingActionButton : null,
    );
  }
}