import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/utils/user_cache.dart';
import '../../localization/localized_text.dart';
import '../../models/user/user_response_model.dart';
import '../../models/user/user_update_request_model.dart';
import '../../services/user/user_service.dart';
import '../../widgets/custom_back_button.dart';

class EditProfileScreen extends StatefulWidget {
  final UserResponseModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const double _topPadding = 100.0;

  late UserService _userService;

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;
  late final TextEditingController _profilePictureUrlController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userService = GetIt.I<UserService>();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _profilePictureUrlController = TextEditingController(text: widget.user.profilePictureUrl ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _profilePictureUrlController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'edit_profile.full_name_required'.localized;
    }
    if (value.trim().length < 5) {
      return 'edit_profile.full_name_min_length'.localized;
    }
    if (value.trim().length > 60) {
      return 'edit_profile.full_name_max_length'.localized;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'edit_profile.email_required'.localized;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'edit_profile.email_invalid'.localized;
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final requestModel = UserUpdateRequestModel(
        email: _emailController.text.trim(),
        fullName: _fullNameController.text.trim(),
        bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        profilePictureUrl: _profilePictureUrlController.text.trim().isNotEmpty
            ? _profilePictureUrlController.text.trim()
            : null,
      );

      final updatedUser = await _userService.updateUser(requestModel);

      // Update the cached user so profile screen reflects changes
      UserCache.setUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('edit_profile.profile_updated_success'.localized),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'edit_profile.profile_update_error'.localized}: $e'),
            backgroundColor: Colors.red,
          ),
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
                    // Profile Fields Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'edit_profile.title'.localized,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Full Name Field
                            TextFormField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                labelText: 'edit_profile.full_name'.localized,
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                              validator: _validateFullName,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),

                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'edit_profile.email'.localized,
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: _validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),

                            // Bio Field
                            TextFormField(
                              controller: _bioController,
                              decoration: InputDecoration(
                                labelText: 'edit_profile.bio'.localized,
                                hintText: 'edit_profile.bio_hint'.localized,
                                prefixIcon: const Icon(Icons.description_outlined),
                              ),
                              maxLines: 3,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),

                            // // Profile Picture URL Field
                            // TextFormField(
                            //   controller: _profilePictureUrlController,
                            //   decoration: InputDecoration(
                            //     labelText: 'edit_profile.`profile_picture_url`'.localized,
                            //     prefixIcon: const Icon(Icons.image_outlined),
                            //   ),
                            //   keyboardType: TextInputType.url,
                            //   textInputAction: TextInputAction.done,
                            // ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
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
                            : ReactiveLocalizedText('edit_profile.save_button'),
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
            heroTag: "edit_profile_back_button",
          ),
        ],
      ),
    );
  }
}
