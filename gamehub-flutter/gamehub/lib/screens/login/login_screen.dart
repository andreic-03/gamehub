import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../config/injection.dart';
import '../../core/viewmodels/auth_view_model.dart';
import '../../localization/localized_text.dart';
import '../../localization/localization_service.dart';
import '../registration/registration_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get the AuthViewModel from the DI container
    final viewModel = getIt<AuthViewModel>();
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 
                               AppBar().preferredSize.height - 
                               MediaQuery.of(context).padding.top - 
                               32, // 2 * padding
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const LocalizedText(
                          "login.login_header",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'login.username'.localized,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'login.password'.localized,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock),
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) => _login(context, authViewModel),
                        ),
                        const SizedBox(height: 24),
                        if (authViewModel.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          ElevatedButton(
                            onPressed: () => _login(context, authViewModel),
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
                                  'login.login_button'.localized,
                                  style: const TextStyle(fontSize: 16),
                                );
                              },
                            ),
                          ),
                        if (authViewModel.hasError) ...[
                          const SizedBox(height: 16),
                          Text(
                            authViewModel.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 16),
                        
                        // Registration Button
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegistrationScreen(),
                              ),
                            );
                          },
                          child: ListenableBuilder(
                            listenable: LocalizationService.instance,
                            builder: (context, child) {
                              return Text(
                                'login.create_account'.localized,
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
      },
    );
  }

  void _login(BuildContext context, AuthViewModel viewModel) async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'login.please_enter_credentials'.localized,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
      );
      return;
    }

    final success = await viewModel.login(
      _usernameController.text,
      _passwordController.text,
    );

    // On successful login:
    // - viewModel.login() sets the token and calls notifyListeners()
    // - The Consumer in main.dart listens to this and automatically rebuilds
    // - The home property switches from LoginScreen to HomeScreen
    // Navigation is now handled by main.dart's Consumer, ensuring proper widget lifecycle
    
    // Show error if login failed
    if (!success && viewModel.hasError) {
      // Show error toast - using try-catch to handle cases where context might be invalid
      try {
        Fluttertoast.showToast(
          msg: viewModel.errorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[800],
          textColor: Colors.white,
        );
      } catch (_) {
        // Context may be invalid if widget was disposed during login
        // Silently ignore - the error state is already set in the viewModel
      }
    }
  }
}