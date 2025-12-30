import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/viewmodels/auth_view_model.dart';
import '../../localization/localized_text.dart';
import '../../models/user/user_password_change_model.dart';
import '../../services/user/user_service.dart';
import '../../widgets/custom_back_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const double _topPadding = 100.0;

  late UserService _userService;
  late AuthViewModel _authViewModel;
  
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userService = GetIt.I<UserService>();
    _authViewModel = GetIt.I<AuthViewModel>();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final requestModel = UserPasswordChangeModel(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
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
            title: ReactiveLocalizedText('settings.change_password'),
            content: ReactiveLocalizedText('settings.password_changed_success'),
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
          SnackBar(content: Text('${'settings.password_change_error'.localized}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, _topPadding, 16.0, 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Password Fields Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'settings.change_password'.localized,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Old Password Field
                            TextFormField(
                              controller: _oldPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'settings.old_password'.localized,
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'app.required'.localized;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // New Password Field
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'settings.new_password'.localized,
                                prefixIcon: Icon(Icons.lock),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'app.required'.localized;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Confirm Password Field
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'settings.confirm_password'.localized,
                                prefixIcon: Icon(Icons.lock_reset),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'app.required'.localized;
                                }
                                if (value != _newPasswordController.text) {
                                  return 'settings.passwords_do_not_match'.localized;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Change Password Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : ReactiveLocalizedText('settings.change_password'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Background barrier to hide scrolling content behind back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _topPadding,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          // Custom back button
          CustomBackButton(
            heroTag: "change_password_back_button",
          ),
        ],
      ),
    );
  }
}

