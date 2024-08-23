import 'package:flutter/material.dart';
import 'package:mobile/api.dart' as api;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'variables.dart';


class SideMenu extends StatefulWidget {
  final Widget body;
  final int selectedIndex ;

  const SideMenu({super.key, required this.body,  required this.selectedIndex});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late int _selectedIndex;

 @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex; // Initialize _selectedIndex with the value from the widget
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove('token');
    setState(() {
      loggedIn = false;
      });


    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully logged out')));
          Navigator.pushReplacementNamed(context, '/login');

    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api
       .isLoggedIn(context).then((value) {
        setState(() {
          loggedIn = value; // Update the second variable here
  });
});

  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Row(
        children: [
          const SizedBox(width: 55),
          Text('SkanTravels',
                style: GoogleFonts.jacquesFrancois(
                  fontSize: 30,
                  color: Colors.black,
                ),
          ),
        ],
      ),
    ),
    drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
            children: [
              const Image(
              image: AssetImage('assets/logo.png'),
              height: 100,
              ),
              Text(
                'SkanTravels',
                style: GoogleFonts.jacquesFrancois(
                  fontSize: 20,
                  color: Color(0xFF1862E7),
                ),
              ),
            ],
            )
          ),
          ListTile(
            title: const Text('Home'),
            leading: const Icon(Icons.home),
            selected: _selectedIndex == 0,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            title: const Text('Favourites'),
            leading: const Icon(Icons.star),
            selected: _selectedIndex == 1,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/favourites');
            },
          ),
          ListTile(
            title: const Text('Profile'),
            leading: const Icon(Icons.person),
            selected: _selectedIndex == 2,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
          const Divider(
            color: Colors.grey,
            thickness: 2,
            indent: 40,
          ),
          ...(loggedIn
              ? [
                  ListTile(
                    title: const Text('Log out'),
                    leading: const Icon(Icons.logout),
                    selected: false,
                    onTap: _logout,
                  )
                ]
              : [
                  ListTile(
                    title: const Text('Register'),
                    leading: const Icon(Icons.add_box_outlined),
                    selected: _selectedIndex == 3,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                  ),
                  ListTile(
                    title: const Text('Login'),
                    leading: const Icon(Icons.login),
                    selected: _selectedIndex == 4,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  )
                ])
        ],
      ),
    ),
    body: widget.body,
  );
}
}