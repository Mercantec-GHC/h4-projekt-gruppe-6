import 'package:flutter/material.dart';
import 'package:mobile/api.dart' as api;
import 'package:shared_preferences/shared_preferences.dart';

class SideMenu extends StatefulWidget {
  final Widget body;

  const SideMenu({super.key, required this.body});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _isLoggedIn = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _postNavigationCallback(dynamic _) async {
    final isLoggedIn = await api.isLoggedIn(context);
    setState(() => _isLoggedIn = isLoggedIn);

    // Close sidebar
    if (mounted && _scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.pop(context);
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove('token');
    setState(() => _isLoggedIn = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully logged out')));
      Navigator.pop(context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api
        .isLoggedIn(context)
        .then((value) => setState(() => _isLoggedIn = value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('SkanTavels'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Home'),
              leading: const Icon(Icons.home),
              selected: _selectedIndex == 0,
              onTap: () {
                // Update the state of the app
                _onItemTapped(0);
                // Then close the drawer
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              title: const Text('Favourites'),
              leading: const Icon(Icons.star),
              selected: _selectedIndex == 1,
              onTap: () {
                // Update the state of the app
                _onItemTapped(1);
                // Then close the drawer
                Navigator.pushReplacementNamed(context, '/favourites');
              },
            ),
            ListTile(
              title: const Text('Profile'),
              leading: const Icon(Icons.person),
              selected: _selectedIndex == 2,
              onTap: () {
                // Update the state of the app
                _onItemTapped(2);
                // Then close the drawer
                Navigator.pushReplacementNamed(context, '/profile');
              },
            ),
            const Divider(
              color: Colors.grey,
              thickness: 2,
              indent: 40,
            ),
            ...(_isLoggedIn
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
                        // Update the state of the app
                        _onItemTapped(3);
                        // Then close the drawer
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                    ),
                    ListTile(
                      title: const Text('Login'),
                      leading: const Icon(Icons.login),
                      selected: _selectedIndex == 4,
                      onTap: () {
                        // Update the state of the app
                        _onItemTapped(4);
                        // Then close the drawer
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
