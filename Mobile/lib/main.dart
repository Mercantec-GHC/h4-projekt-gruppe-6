import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/favorites.dart';
import 'package:mobile/register.dart';
import 'login.dart';
import 'base/sidemenu.dart';
import 'profile.dart';
import 'api.dart' as api;
import 'models.dart';

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
      home: const MyHomePage(),
      initialRoute: '/',
      routes: {
        '/home': (context) => const MyHomePage(),
        '/profile': (context) => const ProfilePage(),
        '/favorites': (context) => const FavoritesPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Favorite> _favorites = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api.isLoggedIn(context).then((isLoggedIn) async {
      if (!isLoggedIn || !mounted) return;

      final response = await api.request(context, api.ApiService.app, 'GET', '/favorites', null);
      if (response == null) return;

      final List<dynamic> favorites = jsonDecode(response);
      setState(() {
        _favorites = favorites.map((favorite) => Favorite(favorite['id'], favorite['user_id'], favorite['lat'], favorite['lng'], favorite['name'], favorite['description'])).toList();
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return SideMenu(
      selectedIndex: 0,
      body: Scaffold(
        key: _scaffoldKey,
        //drawer: navigationMenu,
        body: FlutterMap(
          options: const MapOptions(initialCenter: LatLng(55.9397, 9.5156), initialZoom: 7.0),
          children: [
            openStreetMapTileLayer,
            ..._favorites.map((favorite) =>
              MarkerLayer(markers: [
                Marker(
                  point: LatLng(favorite.lat, favorite.lng),
                  width: 30,
                  height: 50,
                  alignment: Alignment.center,
                  child: const Stack(
                    children: [
                      Icon(Icons.location_pin, size: 30, color: Colors.yellow),
                      Icon(Icons.location_on_outlined, size: 30, color: Colors.black),
                    ]
                  ),
                )
              ])
            ),
          ],
        ),
      ),
    );
  }

  TileLayer get openStreetMapTileLayer => TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
  );
}
