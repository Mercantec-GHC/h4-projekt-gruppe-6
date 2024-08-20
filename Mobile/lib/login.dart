import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
              const TextField(),
              const SizedBox(height: 30),
              const Text('Password'),
              const TextField(obscureText: true, enableSuggestions: false, autocorrect: false),
              const SizedBox(height: 30),
              ElevatedButton(child: const Text('Login'), onPressed: () => Navigator.pop(context)),
              const SizedBox(height: 10),
              TextButton(child: const Text('Registrer konto'), onPressed: () {})
            ]
          )
        )
      )
    );
  }
}
