import 'package:flutter/material.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.title});

  final String title;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
              const Text('Brugernavn'),
              const TextField(),
              const SizedBox(height: 30),
              const Text('Email'),
              const TextField(),
              const SizedBox(height: 30),
              const Text('Password'),
              const TextField(obscureText: true, enableSuggestions: false, autocorrect: false),
              const SizedBox(height: 30),
              ElevatedButton(child: const Text('Registrer'), onPressed: () => Navigator.pop(context)),
              const SizedBox(height: 10),
              TextButton(
                child: const Text('Log ind'),
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Log ind')))
              ),
            ]
          )
        )
      )
    );
  }
}
