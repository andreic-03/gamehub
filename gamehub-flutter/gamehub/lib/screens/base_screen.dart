import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamehub/core/viewmodels/auth_view_model.dart';
import 'package:gamehub/screens/map_screen/map_content.dart';
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
  bool _isRefreshing = false;
  final GlobalKey<HomeContentState> _homeContentKey = GlobalKey<HomeContentState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContent(key: _homeContentKey),
      MapContent(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // If clicking on home button (index 0) and there are game posts, refresh the data
    if (index == 0 && _homeContentKey.currentState != null) {
      if (_homeContentKey.currentState!.hasGamePosts) {
        refreshHomeContent();
      }
    }
  }

  // Method to refresh home content
  Future<void> refreshHomeContent() async {
    if (_homeContentKey.currentState != null) {
      setState(() {
        _isRefreshing = true;
      });
      
      try {
        await _homeContentKey.currentState!.refreshData();
      } finally {
        if (mounted) {
          setState(() {
            _isRefreshing = false;
          });
        }
      }
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
        isRefreshing: _isRefreshing,
      ),
      floatingActionButton: _selectedIndex == 0 ? widget.floatingActionButton : null,
    );
  }
}