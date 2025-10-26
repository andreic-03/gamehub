import 'package:flutter/material.dart';
import 'package:gamehub/core/viewmodels/auth_view_model.dart';
import 'package:gamehub/screens/profile/profile_avatar.dart';
import 'package:gamehub/screens/profile/profile_screen.dart';
import 'package:gamehub/screens/profile/profile_view_model.dart';
import 'package:gamehub/screens/settings/settings_screen.dart';
import 'package:gamehub/localization/localized_text.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../services/auth/auth_service.dart';

typedef ScreenSelectionCallback = void Function(int);

@injectable
class AppDrawer extends StatefulWidget {
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

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final ProfileViewModel _profileViewModel = GetIt.instance<ProfileViewModel>();
  String? _fullName;
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _profileViewModel.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _fullName = user.fullName;
        _profilePictureUrl = user.profilePictureUrl;
      });
    }
  }

  void _handleLogout(BuildContext context) async {
    final success = await widget._authViewModel.logout();
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
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Row(
              children: [
                ProfileAvatar(
                  imageUrl: _profilePictureUrl,
                  fullName: _fullName ?? "User",
                  radius: 40,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LocalizedText(
                        'app.welcome',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _fullName ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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