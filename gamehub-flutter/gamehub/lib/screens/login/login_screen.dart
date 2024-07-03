import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/injection.dart';
import '../home/home_screen.dart';
import 'login_view_model.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<LoginViewModel>(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(title: Text("GameHub")),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Login",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  if (viewModel.isLoading)
                    CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: () => _login(context, viewModel),
                      child: Text('Login'),
                    ),
                  if (viewModel.errorMessage != null)
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _login(BuildContext context, LoginViewModel viewModel) async {
    final success = await viewModel.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }
}
