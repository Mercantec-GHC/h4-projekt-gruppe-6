import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'api.dart' as api;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'H4 Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SkanTravels'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _isLoggedIn = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove('token');
    setState(() => _isLoggedIn = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully logged out')));
      Navigator.pop(context);
    }
  }

  Future<void> _postNavigationCallback(dynamic _) async {
    final isLoggedIn = await api.isLoggedIn(context);
    setState(() => _isLoggedIn = isLoggedIn);

    // Close sidebar
    if (mounted && _scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.pop(context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api.isLoggedIn(context)
        .then((value) => setState(() => _isLoggedIn = value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: navigationMenu,
      body: FlutterMap(
        options: const MapOptions(
            initialCenter: LatLng(55.9397, 9.5156), initialZoom: 7.0),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          )
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _isLoggedIn ? [] : [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage(title: "Login")))
                .then(_postNavigationCallback);
            },
            tooltip: 'Login',
            child: const Icon(Icons.login),
          ),
        ],
      ),
    );
  }

  Drawer get navigationMenu => Drawer(
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
                Navigator.pop(context);
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
                Navigator.pop(context);
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
                Navigator.pop(context);
              },
            ),
            const Divider(
              color: Colors.grey,
              thickness: 2,
              indent: 40,
            ),
            ...(
              _isLoggedIn ? [
                ListTile(
                  title: const Text('Log out'),
                  leading: const Icon(Icons.logout),
                  selected: false,
                  onTap: _logout,
                )
              ] : [
                ListTile(
                  title: const Text('Register'),
                  leading: const Icon(Icons.add_box_outlined),
                  selected: _selectedIndex == 3,
                  onTap: () {
                    // Update the state of the app
                    _onItemTapped(3);
                    // Then close the drawer
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage(title: 'Register')))
                        .then(_postNavigationCallback);
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Login')))
                        .then(_postNavigationCallback);
                  },
                )
              ]
            )
          ]
        ),
      );
}
