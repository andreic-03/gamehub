import 'package:flutter/material.dart';
import 'package:gamehub/providers/auth_provider.dart';
import 'package:gamehub/screens/profile/profile_avatar.dart';
import 'package:injectable/injectable.dart';
import '../services/auth/auth_service.dart';

typedef ScreenSelectionCallback = void Function(int);

@injectable
class AppDrawer extends StatelessWidget {
  final ScreenSelectionCallback onSelectScreen;
  final AuthService _authService;
  final AuthProvider _authProvider;

  @factoryMethod
  AppDrawer({
    Key? key,
    required this.onSelectScreen,
    required AuthService authService,
    required AuthProvider authProvider,
  })  : _authService = authService,
        _authProvider = authProvider,
        super(key: key);

  void _handleLogout(BuildContext context) async {
    await _authService.logout();
    _authProvider.clearToken();
    Navigator.pop(context);
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Row(
              children: [
                ProfileAvatar(
                    imageUrl: null,
                    firstName: "John",
                    radius: 40,
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'John Doe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              onSelectScreen(0);
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              onSelectScreen(1);
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              onSelectScreen(2);
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}