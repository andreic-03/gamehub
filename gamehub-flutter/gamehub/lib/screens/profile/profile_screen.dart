import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamehub/screens/profile/profile_avatar.dart';
import 'package:gamehub/screens/profile/profile_view_model.dart';
import 'package:get_it/get_it.dart';

import '../../core/viewmodels/auth_view_model.dart';
import '../../models/user/user_password_change_model.dart';
import '../../models/user/user_response_model.dart';
import '../../services/user/user_service.dart';
import '../../widgets/custom_back_button.dart';
import '../../localization/localization_service.dart';
import '../../localization/localized_text.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  late ProfileViewModel _profileViewModel;
  late UserService _userService;
  late AuthViewModel _authViewModel;
  UserResponseModel? _user;

  @override
  void initState() {
    super.initState();
    _profileViewModel = GetIt.I<ProfileViewModel>();
    _userService = GetIt.I<UserService>();
    _authViewModel = GetIt.I<AuthViewModel>();
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

  Future<void> _changePassword() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: ReactiveLocalizedText('profile.change_password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'profile.old_password'.localized,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'app.required'.localized;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'profile.new_password'.localized,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'app.required'.localized;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'profile.confirm_password'.localized,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'app.required'.localized;
                  }
                  if (value != newPasswordController.text) {
                    return 'profile.passwords_do_not_match'.localized;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: ReactiveLocalizedText('app.cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: ReactiveLocalizedText('app.confirm'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final requestModel = UserPasswordChangeModel(
          oldPassword: oldPasswordController.text,
          newPassword: newPasswordController.text,
        );
        
        await _userService.changePassword(requestModel);
        
        // Clear the authentication token since the backend invalidates the session
        _authViewModel.clearToken();
        
        if (mounted) {
          // Show success dialog first
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: ReactiveLocalizedText('profile.change_password'),
              content: ReactiveLocalizedText('profile.password_changed_success'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: ReactiveLocalizedText('app.ok'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${'profile.password_change_error'.localized}: $e')),
          );
        }
      }
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
                              const SizedBox(height: 24),
                              
                              // Edit Profile Button
                              ElevatedButton(
                                onPressed: () {
                                  // Add functionality for profile screen
                                },
                                child: ReactiveLocalizedText('profile.edit_profile'),
                              ),
                              const SizedBox(height: 16),
                              
                              // Change Password Button
                              ElevatedButton(
                                onPressed: _changePassword,
                                child: ReactiveLocalizedText('profile.change_password'),
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