import 'dart:math';
import 'dart:developer' as useMAN;
import 'package:flutter/material.dart';
import 'package:mobile/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart' as api;
import 'base/variables.dart';

class EditProfilePage extends StatefulWidget {
   final User? userData;

  const EditProfilePage({super.key, required this.userData});


  @override
  State<EditProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<EditProfilePage> {
  TextEditingController usernameInput = TextEditingController();
  TextEditingController emailInput = TextEditingController();
  TextEditingController passwordInput = TextEditingController();
  TextEditingController confirmPasswordInput = TextEditingController();


 @override
  void initState() {
    super.initState();
    // Initialize the controllers with existing data
    usernameInput.text = widget.userData!.username;
    emailInput.text = widget.userData!.email;
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    usernameInput.dispose();
    emailInput.dispose();
    passwordInput.dispose();
    confirmPasswordInput.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (passwordInput.text != confirmPasswordInput.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');

    if (!mounted) {
      return;
    }

    final response = await api.request(context, api.ApiService.auth, 'PUT', '/api/users', {
      'id' : id,
      'username': usernameInput.text,
      'email': emailInput.text,
      'password': passwordInput.text,
    });

    if (!mounted) {
      return;
    }

    useMAN.log('data');

    if (response != null) {
      user = User(
        id!,
        emailInput.text,
        usernameInput.text,
        DateTime.now(),
      );

      Navigator.of(context).pop(); // Close the dialog
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong! Please contact an admin.')),
      );
    }
  }

  void _deleteProfile(BuildContext context) {
     showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete your profile?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                String? id = prefs.getString('id');

                final response = await api.request(context, api.ApiService.auth, 'DELETE', '/api/users/$id', null);
                
                if (response != null) {
                  prefs.remove('token');
                  prefs.remove('id');

                  setState(() {
                    user = null;
                  });

                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop();

                  Navigator.pushReplacementNamed(context, '/register');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Something went wrong! Please contact an admin.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigates back when the back button is pressed
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameInput,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailInput,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordInput,
              decoration: InputDecoration(labelText: 'New password'),
            ),
            TextField(
              controller: confirmPasswordInput,
              decoration: InputDecoration(labelText: 'Repeat new password'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _saveProfile, // Save and pop
                  child: Text('Save'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _deleteProfile(context),
                  child: Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red, // Red text
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

