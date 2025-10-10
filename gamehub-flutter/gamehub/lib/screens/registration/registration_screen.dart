import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gamehub/screens/registration/registration_view_model.dart';
import '../../config/injection.dart';
import '../../localization/localized_text.dart';
import '../../localization/localization_service.dart';
import '../login/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the RegistrationViewModel from the DI container
    final viewModel = getIt<RegistrationViewModel>();
    
    return Scaffold(
          appBar: AppBar(
            title: const LocalizedText("registration.title"),
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const LocalizedText(
                        "registration.header",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Full Name Field
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'registration.full_name'.localized,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) => viewModel.validateFullName(value),
                      ),
                      const SizedBox(height: 16),
                      
                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'registration.username'.localized,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) => viewModel.validateUsername(value),
                      ),
                      const SizedBox(height: 16),
                      
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'registration.email'.localized,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) => viewModel.validateEmail(value),
                      ),
                      const SizedBox(height: 16),
                      
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'registration.password'.localized,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        validator: (value) => viewModel.validatePassword(value),
                      ),
                      const SizedBox(height: 16),
                      
                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'registration.confirm_password'.localized,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) => viewModel.validateConfirmPassword(
                          value, 
                          _passwordController.text
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Register Button
                      if (viewModel.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        ElevatedButton(
                          onPressed: () => _register(context, viewModel),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: ListenableBuilder(
                            listenable: LocalizationService.instance,
                            builder: (context, child) {
                              return Text(
                                'registration.register_button'.localized,
                                style: const TextStyle(fontSize: 16),
                              );
                            },
                          ),
                        ),
                      
                      // Error Message
                      if (viewModel.hasError) ...[
                        const SizedBox(height: 16),
                        Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Back to Login Button
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: ListenableBuilder(
                          listenable: LocalizationService.instance,
                          builder: (context, child) {
                            return Text(
                              'registration.back_to_login'.localized,
                              style: const TextStyle(fontSize: 16),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
  }

  void _register(BuildContext context, RegistrationViewModel viewModel) async {
    // Clear any previous errors
    viewModel.clearError();
    
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate using the view model's validation method
    if (!viewModel.validateForm(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      fullName: _fullNameController.text,
    )) {
      Fluttertoast.showToast(
        msg: 'registration.please_fix_errors'.localized,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
      );
      return;
    }

    final userResponse = await viewModel.register(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _fullNameController.text,
    );

    if (userResponse != null) {
      Fluttertoast.showToast(
        msg: 'registration.success_message'.localized,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green[800],
        textColor: Colors.white,
      );
      
      // Navigate back to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } else if (viewModel.hasError) {
      Fluttertoast.showToast(
        msg: viewModel.errorMessage!,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
      );
    }
  }
}
