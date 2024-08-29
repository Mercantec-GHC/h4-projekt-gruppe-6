import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/favorites.dart';
import 'package:mobile/register.dart';
import 'login.dart';
import 'base/sidemenu.dart';
import 'profile.dart';
import 'models.dart';
import 'api.dart' as api;
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
  double _zoom = 7.0;
  final TextEditingController searchBarInput =TextEditingController(text: '');

  void _onTap(TapPosition _, LatLng point) async {
    setState(() => _selectedPoint = point);

    final dynamic location;
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse.php?lat=${point.latitude}&lon=${point.longitude}&zoom=${max(12, _zoom.ceil())}&format=jsonv2'),
        headers: {'User-Agent': 'SkanTravels/1.0'},
      );

      if (mounted && response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to fetch information about this location (HTTP ${response.statusCode})')));
        debugPrint(response.body);
        return;
      }

      location = jsonDecode(response.body);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to fetch information about this location')));

      setState(() => _selectedPoint = null);

      return;
    }

    if (!mounted) return;

    if (location['name'] != null && location['display_name'] != null) {
      await _showLocation(point, location['name'], location['display_name']);
    }

    setState(() => _selectedPoint = null);
  }

  Future<void> _showLocation(LatLng point, String name, String description) async {
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
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                    const SizedBox(height: 10),
                    Text(description),
                  ],
                )),
                Column(children: [
                  IconButton(
                      icon: const Icon(Icons.star),
                      iconSize: 32,
                      color: _favorites.where((fav) => fav.lat == point.latitude && fav.lng == point.longitude).isEmpty ? Colors.grey : Colors.yellow,
                      onPressed: () => _toggleFavorite(point, name, description, setModalState, context)
                  ),
                  const IconButton(icon: Icon(Icons.rate_review), iconSize: 32, onPressed: null),
                ]),
              ]),
            ),
          ]);
        });
      },
    );
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
      final newFavorite = await api.request(
          context, api.ApiService.app, 'POST', '/favorites',
          {'lat': point.latitude, 'lng': point.longitude, 'name': name, 'description': description},
      );

      if (newFavorite == null) {
        navigator.pop();
        return;
      }

      setState(() {
        _favorites.add(Favorite.fromJson(jsonDecode(newFavorite)));
      });
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

  Future<void> _fetchFavorites() async {
    final response = await api.request(context, api.ApiService.app, 'GET', '/favorites', null);
    if (response == null) return;

    final List<dynamic> favorites = jsonDecode(response);
    setState(() {
      _favorites = favorites.map((favorite) => Favorite.fromJson(favorite)).toList();
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

  Future<void> GetOpenStreetMapArea() async {
  final dynamic location;
  LatLng point;

  if (searchBarInput.text != '') {
    final response = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/search.php?q=${searchBarInput.text}&format=jsonv2'),
      headers: {'User-Agent': 'SkanTravels/1.0'},
    );

    location = jsonDecode(response.body);

    if (location is List && location.isNotEmpty) {
      final firstResult = location[0];  // Pick the first entry

      if (firstResult['lat'] != null && firstResult['lon'] != null && firstResult['name'] != null && firstResult['display_name'] != null) {
        double lat = double.parse(firstResult['lat']);
        double lon = double.parse(firstResult['lon']);
        point = LatLng(lat, lon);
        setState(() => _selectedPoint = point);
        await _showLocation(point, firstResult['name'], firstResult['display_name']);
      }
    }
  }
}

   @override
  void dispose() {
    searchBarInput.dispose();
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {
    return SideMenu(
      selectedIndex: 0,
      body: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(55.9397, 9.5156),
                initialZoom: _zoom,
                onTap: _onTap,
                onPositionChanged: (pos, _) => _zoom = pos.zoom,
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
                        ],
                      ),
                    )
                  ]),
                ..._favorites.map((favorite) => MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(favorite.lat, favorite.lng),
                          width: 30,
                          height: 50,
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              IconButton(
                                padding: const EdgeInsets.only(bottom: 10),
                                icon: const Icon(Icons.location_pin, size: 30, color: Colors.yellow),
                                onPressed: () => _showLocation(LatLng(favorite.lat, favorite.lng), favorite.name, favorite.description),
                              ),
                              IconButton(
                                padding: const EdgeInsets.only(bottom: 10),
                                icon: const Icon(Icons.location_on_outlined, size: 30, color: Colors.black),
                                onPressed: () => _showLocation(LatLng(favorite.lat, favorite.lng), favorite.name, favorite.description),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CupertinoSearchTextField(
                              controller: searchBarInput,
                              suffixMode: OverlayVisibilityMode.never,
                              backgroundColor: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 2, // Position the button at the bottom-right
                        bottom: 4.5,
                        child: ElevatedButton(
                          onPressed: GetOpenStreetMapArea,
                          child: const Text('Search'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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