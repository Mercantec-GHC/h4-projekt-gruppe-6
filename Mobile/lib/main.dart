import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong2/latlong.dart";
import 'package:mobile/register.dart';
import 'base/sidemenu.dart';
import "login.dart";
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
      home: const MyHomePage(title: 'SkanTravels'),
      initialRoute: '/',
      routes: {
        '/home': (context) => const MyHomePage(
              title: 'SkasdanTravels',
            ),
        '/profile': (context) => const ProfilePage(),
        '/login': (context) => const LoginPage(title: 'SkanTravels'),
        '/register': (context) => const RegisterPage(title: 'SkanTravels'),
      },
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
  @override
  Widget build(BuildContext context) {
    return SideMenu(
      body: Scaffold(
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
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginPage(title: "Login")));
              },
              tooltip: 'Login',
              child: const Icon(Icons.login),
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
