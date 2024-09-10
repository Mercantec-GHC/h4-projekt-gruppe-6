import 'package:flutter/material.dart';
import 'package:mobile/base/sidemenu.dart';
import 'package:mobile/models.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'api.dart' as api;
import 'base/variables.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailInput = TextEditingController();
  final passwordInput = TextEditingController();

  Future<void> _login() async {
    final response = await api.request(context, api.ApiService.auth, 'POST', '/api/Users/login', {
      'email': emailInput.text,
      'password': passwordInput.text,
    });

    if (response == null) return;

    // Assuming token is a JSON string
    Map<String, dynamic> json = jsonDecode(response);
    models.Login jsonUser = models.Login.fromJson(json);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', jsonUser.token);
    prefs.setString('id', jsonUser.id);
    prefs.setString('refresh-token', jsonUser.refreshToken);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully logged in')));
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

    @override
    void initState() {
      super.initState();
      setState(() {
        user = null; 
      });
    }

  @override
  Widget build(BuildContext context) {
    return SideMenu(
      selectedIndex: 4,
      body: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(40),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(children: [
                const Image(image: AssetImage('assets/logo.png'), height: 200),
                Text(
                  'SkanTravels',
                  style: GoogleFonts.jacquesFrancois(
                    fontSize: 30,
                    color: const Color(0xFF1862E7),
                  ),
                ),
                const SizedBox(height: 40),
                const Text('Email'),
                TextField(controller: emailInput),
                const SizedBox(height: 30),
                const Text('Password'),
                TextField(
                  controller: passwordInput,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                ),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: _login, child: const Text('Login')),
                const SizedBox(height: 10),
                const Text('or'),
                TextButton(
                  child: const Text('Register account'),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/register')
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailInput.dispose();
    passwordInput.dispose();
    super.dispose();
  }
}
