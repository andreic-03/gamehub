import 'package:flutter/material.dart';
import 'package:gamehub/screens/profile/profile_avatar.dart';
import 'package:gamehub/screens/profile/profile_view_model.dart';
import 'package:get_it/get_it.dart';

import '../../models/user/user_response_model.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  late ProfileViewModel _profileViewModel;
  UserResponseModel? _user;

  @override
  void initState() {
    super.initState();
    _profileViewModel = GetIt.I<ProfileViewModel>();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final user = await _profileViewModel.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _profileViewModel.isLoading
                ? CircularProgressIndicator()
                : _user != null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileAvatar(
                  firstName: _user!.fullName,
                  imageUrl: _user!.profilePictureUrl,
                  radius: 40,
                ),
                const SizedBox(height: 20),
                Text(_user!.fullName), // Assuming 'name' is a field in UserResponseModel
                Text('Level: ${_user!.username}'), // Assuming 'level' is a field in UserResponseModel
                ElevatedButton(
                  onPressed: () {
                    // Add functionality for profile screen
                  },
                  child: const Text('Edit Profile'),
                ),
              ],
            )
                : Text(_profileViewModel.errorMessage ?? 'Error loading profile'),
          ),
          // Custom back button
          Positioned(
            top: 50,
            left: 16,
            child: FloatingActionButton.small(
              heroTag: "profile_back_button",
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.arrow_back),
            ),
          ),
        ],
      ),
    );
  }
}