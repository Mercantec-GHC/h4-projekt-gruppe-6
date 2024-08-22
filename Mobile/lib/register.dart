import 'package:flutter/material.dart';
import 'package:mobile/base/sidemenu.dart';
import 'api.dart' as api;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameInput = TextEditingController();
  final emailInput = TextEditingController();
  final passwordInput = TextEditingController();
  final confirmPasswordInput = TextEditingController();

  Future<void> _register() async {
    if (passwordInput.text != confirmPasswordInput.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    final result = await api.request(context, api.ApiService.auth, 'POST', '/api/Users', {
      'username': usernameInput.text,
      'email': emailInput.text,
      'password': passwordInput.text,
    });

    if (result == null) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully registered, please login')));
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SideMenu(
      body: Scaffold(
        body: Center(
          child: Container(
            constraints: const BoxConstraints(minWidth: 100, maxWidth: 400),
            child: Column(children: [
              const SizedBox(height: 80),
              const Text('Username'),
              TextField(controller: usernameInput),
              const SizedBox(height: 30),
              const Text('Email'),
              TextField(controller: emailInput),
              const SizedBox(height: 30),
              const Text('Password'),
              TextField(
                controller: passwordInput,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false
              ),
              const SizedBox(height: 30),
              const Text('Confirm Password'),
              TextField(
                controller: confirmPasswordInput,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                  onPressed: _register, child: const Text('Register')),
              const SizedBox(height: 10),
              TextButton(
                  child: const Text('Login'),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login')),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameInput.dispose();
    emailInput.dispose();
    passwordInput.dispose();
    confirmPasswordInput.dispose();
    super.dispose();
  }
}
