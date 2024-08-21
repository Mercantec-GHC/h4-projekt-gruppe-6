import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register.dart';
import 'api.dart' as api;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailInput = TextEditingController();
  final passwordInput = TextEditingController();

  Future<void> _login() async {
    final token = await api.request(context, api.ApiService.auth, 'POST', '/api/Users/login', {
      'email': emailInput.text,
      'password': passwordInput.text,
    });

    if (token == null) return;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully logged in')));
      Navigator.pop(context);
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
              const Text('Email'),
              TextField(controller: emailInput),
              const SizedBox(height: 30),
              const Text('Password'),
              TextField(controller: passwordInput, obscureText: true, enableSuggestions: false, autocorrect: false),
              const SizedBox(height: 30),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
              const SizedBox(height: 10),
              TextButton(
                child: const Text('Register account'),
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterPage(title: 'Register'))),
              )
            ]
          )
        )
      )
    );
  }

  @override
  void dispose() {
    emailInput.dispose();
    passwordInput.dispose();
    super.dispose();
  }
}
