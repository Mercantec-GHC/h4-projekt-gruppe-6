import 'package:flutter/material.dart';
import 'base/sidemenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart' as api;


class ProfilePage extends StatefulWidget {
  final String id;

  const ProfilePage({super.key, required this.id});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _id;

 @override
  void initState() {
    super.initState();
    _id = widget.id; // Initialize _selectedIndex with the value from the widget
  }

Future<void> _getUser() async {
    final token = await api
        .request(context, api.ApiService.auth, 'GET', '/api/Users/$_id', {
    });

    if (token == null) return;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully logged in')));
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SideMenu(
      selectedIndex: 2,
      body: Stack(
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Your Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Username',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'email@example.com',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    // Add your edit action here
                  },
                  child: const Text('Edit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
