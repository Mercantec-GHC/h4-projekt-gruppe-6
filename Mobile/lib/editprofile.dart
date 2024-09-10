
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/models.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart' as api;
import 'base/variables.dart';

class EditProfilePage extends StatefulWidget {
   final models.User? userData;
   
  const EditProfilePage({super.key, required this.userData});


  @override
  State<EditProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<EditProfilePage> {
  TextEditingController usernameInput = TextEditingController();
  TextEditingController emailInput = TextEditingController();
  TextEditingController passwordInput = TextEditingController();
  TextEditingController confirmPasswordInput = TextEditingController();
  File? _selectedImage;

  set userData(models.User userData) {}


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

 Future _pickImageFromGallery() async{
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  Future _pickImageFromCamera() async{
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  

 void _saveProfile() async {
  if (passwordInput.text != confirmPasswordInput.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Passwords do not match')));
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  String? id = prefs.getString('id');

  if (!mounted) return;

  if (id != null) {
    final response = await api.putUser(
      context, 
      api.ApiService.auth, 
      'PUT', 
      '/api/users', 
      {
        'id': id,
        'username': usernameInput.text,
        'email': emailInput.text,
        'password': passwordInput.text,
      },
      _selectedImage // Pass the selected image to the putUser function
    );

    if (!mounted) return;

    if (response != null) {
      setState(() {
        user = null;
      });

      Navigator.of(context).pop(); // Close the dialog
      Navigator.pushReplacementNamed(context, '/profile');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong! Please contact an admin.')),
      );
    } 
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
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailInput,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordInput,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            TextField(
              controller: confirmPasswordInput,
              decoration: const InputDecoration(labelText: 'Repeat new password'),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Profile Picture', style: TextStyle(fontSize: 17)),
                if (_selectedImage != null)
                  ClipOval(
                    child: Image(
                      image: FileImage(_selectedImage!),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (user!.profilePicture != null && user!.profilePicture.isNotEmpty)
                  ClipOval(
                    child: Image(
                      image: NetworkImage(user!.profilePicture),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  const Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Colors.grey,
                  ),
                if (_selectedImage != null)
                  Text(_selectedImage!.path.toString()),
                  //until here
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Change using'),
                      TextButton(onPressed: _pickImageFromGallery, child: const Text('Gallery')),
                      const SizedBox(width: 5),
                      const Text('or'),
                      const SizedBox(width: 5),
                      TextButton(onPressed: _pickImageFromCamera, child: const Text('Camera'))
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _saveProfile, // Save and pop
                  child: const Text('Save'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _deleteProfile(context),
                  child: const Text('Delete'),
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

