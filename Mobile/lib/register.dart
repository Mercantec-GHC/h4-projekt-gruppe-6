import 'package:flutter/material.dart';
import 'login.dart';
import 'api.dart' as api;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.title});

  final String title;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameInput = TextEditingController();
  final emailInput = TextEditingController();
  final passwordInput = TextEditingController();

  Future<void> _register() async {
    final result = await api.request(context, api.ApiService.auth, 'POST', '/api/Users', {
      'username': usernameInput.text,
      'email': emailInput.text,
      'password': passwordInput.text,
    });

    if (result == null) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully registered, please login')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Log ind')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(minWidth: 100, maxWidth: 400),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Text('Username'),
              TextField(controller: usernameInput),
              const SizedBox(height: 30),
              const Text('Email'),
              TextField(controller: emailInput),
              const SizedBox(height: 30),
              const Text('Password'),
              TextField(controller: passwordInput, obscureText: true, enableSuggestions: false, autocorrect: false),
              const SizedBox(height: 30),
              ElevatedButton(onPressed: _register, child: const Text('Register')),
              const SizedBox(height: 10),
              TextButton(
                child: const Text('Login'),
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Login')))
              ),
            ]
          )
        )
      )
    );
  }

  @override
  void dispose() {
    usernameInput.dispose();
    emailInput.dispose();
    passwordInput.dispose();
    super.dispose();
  }
}
