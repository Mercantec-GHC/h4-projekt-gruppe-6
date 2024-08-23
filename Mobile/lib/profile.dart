import 'package:flutter/material.dart';
import 'package:mobile/base/variables.dart';
import 'package:mobile/models.dart';
import 'base/sidemenu.dart';
import 'package:mobile/base/variables.dart';




class ProfilePage extends StatefulWidget {

  const ProfilePage({super.key});
  //const ProfilePage({super.key, required this.id});


  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
    late User userData;

  @override
    void initState() {
    super.initState();

    // Check if the user is logged in when the page is entered
    if (loggedIn == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in')));
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
    
    setState(() {
      userData = user!;
    });
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
