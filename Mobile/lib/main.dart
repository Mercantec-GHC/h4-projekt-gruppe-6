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
import 'package:http/http.dart' as http;

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
  LatLng? _selectedPoint;

  void _showLocation(TapPosition _, LatLng point) async {
    setState(() => _selectedPoint = point);

    final dynamic location;
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse.php?lat=${point.latitude}&lon=${point.longitude}&zoom=18&format=jsonv2'),
        headers: {'User-Agent': 'SkanTravels/1.0'},
      );

      location = jsonDecode(response.body);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to fetch information about this location')));

      setState(() => _selectedPoint = null);

      return;
    }

    if (!mounted) return;

    await showModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.3),
      context: context,
      builder: (builder) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
          return Wrap(children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              child: Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(location['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                    const SizedBox(height: 10),
                    Text(location['display_name']),
                  ],
                )),
                Column(children: [
                  IconButton(
                    icon: const Icon(Icons.star),
                    iconSize: 32,
                    color: _favorites.where((fav) => fav.lat == point.latitude && fav.lng == point.longitude).isEmpty ? Colors.grey : Colors.yellow,
                    onPressed: () => _toggleFavorite(point, location['name'], location['display_name'], setModalState, context)
                  ),
                  const IconButton(icon: Icon(Icons.rate_review), iconSize: 32, onPressed: null),
                ]),
              ]),
            ),
          ]);
        });
      },
    );

    setState(() => _selectedPoint = null);
  }

  void _toggleFavorite(LatLng point, String name, String description, StateSetter setModalState, BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final favorite = _favorites.where((fav) => fav.lat == point.latitude && fav.lng == point.longitude).firstOrNull;

    if (!await api.isLoggedIn(context)) {
      messenger.showSnackBar(const SnackBar(content: Text('You need to login to do that'), behavior: SnackBarBehavior.floating));
      navigator.pop();
      return;
    }

    if (!context.mounted) return;

    if (favorite == null) {
      if (await api.request(context, api.ApiService.app, 'POST', '/favorites', {'lat': point.latitude, 'lng': point.longitude}) == null) {
        navigator.pop();
        return;
      }

      _fetchFavorites();
      setModalState(() {});

      return;
    }

    if (await api.request(context, api.ApiService.app, 'DELETE', '/favorites/${favorite.id}', null) == null) {
      navigator.pop();
      return;
    }

    setState(() {
      _favorites = _favorites.where((fav) => fav.id != favorite.id).toList();
    });
    setModalState(() {});
  }

  void _fetchFavorites() async {
    final response = await api.request(context, api.ApiService.app, 'GET', '/favorites', null);
    if (response == null) return;

    final List<dynamic> favorites = jsonDecode(response);
    setState(() {
      _favorites = favorites.map((favorite) => Favorite(favorite['id'], favorite['user_id'], favorite['lat'], favorite['lng'], favorite['name'], favorite['description'])).toList();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api.isLoggedIn(context).then((isLoggedIn) {
      if (!isLoggedIn || !mounted) return;

      _fetchFavorites();
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
          options: MapOptions(
            initialCenter: const LatLng(55.9397, 9.5156),
            initialZoom: 7.0,
            onTap: _showLocation,
          ),
          children: [
            openStreetMapTileLayer,
            if (_selectedPoint != null)
              MarkerLayer(markers: [
                Marker(
                  point: _selectedPoint!,
                  width: 30,
                  height: 50,
                  alignment: Alignment.center,
                  child: const Stack(
                      children: [
                        Icon(Icons.location_pin, size: 30, color: Colors.red),
                        Icon(Icons.location_on_outlined, size: 30, color: Colors.black),
                      ]
                  ),
                )
              ]),
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
              ]),
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
