import 'package:flutter/material.dart';
import 'package:gamehub/core/viewmodels/auth_view_model.dart';
import 'package:gamehub/screens/profile/profile_avatar.dart';
import 'package:gamehub/screens/profile/profile_screen.dart';
import 'package:gamehub/screens/settings/settings_screen.dart';
import 'package:gamehub/localization/localized_text.dart';
import 'package:injectable/injectable.dart';
import '../services/auth/auth_service.dart';

typedef ScreenSelectionCallback = void Function(int);

@injectable
class AppDrawer extends StatelessWidget {
  final ScreenSelectionCallback onSelectScreen;
  final AuthService _authService;
  final AuthViewModel _authViewModel;

  @factoryMethod
  AppDrawer({
    Key? key,
    required this.onSelectScreen,
    required AuthService authService,
    required AuthViewModel authViewModel,
  })  : _authService = authService,
        _authViewModel = authViewModel,
        super(key: key);

  void _handleLogout(BuildContext context) async {
    final success = await _authViewModel.logout();
    if (success) {
      Navigator.pop(context);
      Navigator.of(context).pushReplacementNamed('/login');
    }
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
                    fullName: "John",
                    radius: 40,
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LocalizedText(
                      'app.welcome',
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
          // ListTile(
          //   leading: Icon(Icons.home),
          //   title: Text('Home'),
          //   onTap: () {
          //     onSelectScreen(0);
          //     Navigator.pop(context); // Close the drawer
          //   },
          // ),
          // ListTile(
          //   leading: Icon(Icons.person),
          //   title: Text('Profile'),
          //   onTap: () {
          //     onSelectScreen(1);
          //     Navigator.pop(context); // Close the drawer
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.person),
            title: LocalizedText('navigation.profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileContent(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: LocalizedText('navigation.settings'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: LocalizedText('navigation.logout'),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}