import 'package:flutter/material.dart';
import 'package:gamehub/screens/profile/profile_avatar.dart';
import 'package:gamehub/screens/profile/profile_view_model.dart';
import 'package:get_it/get_it.dart';

import '../../models/user/user_response_model.dart';
import '../../widgets/custom_back_button.dart';
import '../../localization/localized_text.dart';

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
          _profileViewModel.isLoading
              ? Center(child: CircularProgressIndicator())
              : _user != null
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 150.0, left: 50.0, right: 50.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                              // Large Profile Avatar
                              ProfileAvatar(
                                fullName: _user!.fullName,
                                imageUrl: _user!.profilePictureUrl,
                                radius: 50,
                              ),
                              const SizedBox(height: 24),
                              
                              // User Name
                              Text(
                                _user!.username,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 80),
                              
                              // Stats Grid Section (3 columns, 2 rows)
                              Row(
                                children: [
                                  // Column 1
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          child: Text(
                                            'Test-Level',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        ReactiveLocalizedText(
                                          'profile.level',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  
                                  // Column 2
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          child: Text(
                                            '200',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        ReactiveLocalizedText(
                                          'profile.games_played',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  
                                  // Column 3
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          child: Text(
                                            'TBD',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          'TBD',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 35),
                              
                              // Edit Profile Button
                              ElevatedButton(
                                onPressed: () {
                                  // Add functionality for profile screen
                                },
                                child: ReactiveLocalizedText('profile.edit_profile'),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                    )
                  : Center(
                      child: _profileViewModel.errorMessage != null
                          ? Text(
                              _profileViewModel.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            )
                          : ReactiveLocalizedText(
                              'profile.error_loading',
                              style: const TextStyle(color: Colors.red),
                            ),
                    ),
          // Custom back button
          CustomBackButton(
            heroTag: "profile_back_button",
          ),
        ],
      ),
    );
  }
}