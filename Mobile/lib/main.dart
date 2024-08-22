import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/favourites.dart';
import 'package:mobile/register.dart';
import 'login.dart';
import 'base/sidemenu.dart';
import 'profile.dart';

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
        '/favourites': (context) => const FavouritesPage(),
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
  @override
  Widget build(BuildContext context) {
    return SideMenu(
      selectedIndex: 0,
      body: Scaffold(
        key: _scaffoldKey,
        //drawer: navigationMenu,
        body: FlutterMap(
          options: const MapOptions(
              initialCenter: LatLng(55.9397, 9.5156), initialZoom: 7.0),
          children: [
            openStreetMapTileLayer,
            const MarkerLayer(markers: [
              Marker(
                point: LatLng(56.465511, 9.411366),
                width: 60,
                height: 100,
                alignment: Alignment.center,
                child: Icon(
                  Icons.location_pin,
                  size: 60,
                  color: Colors.purple,
                ),
              ),
            ]),
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
