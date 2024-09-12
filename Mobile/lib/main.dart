import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/createreview.dart';
import 'package:mobile/favorites.dart';
import 'package:mobile/register.dart';
import 'package:mobile/reviewlist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'base/sidemenu.dart';
import 'profile.dart';
import 'models.dart';
import 'package:geolocator/geolocator.dart';
import 'api.dart' as api;
import 'package:http/http.dart' as http;

void main() async {
  // Refresh JWT on startup
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getString("token") != null && prefs.getString("refresh-token") != null) {
    final token = await api.request(null, api.ApiService.auth, "POST", "/RefreshToken", {'refreshToken': prefs.getString("refresh-token")});
    if (token != null) prefs.setString("token", token);
  }

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
        '/reviews': (context) => const ReviewListPage(),
        '/create-review': (context) => const CreateReviewPage(),
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
  List<Review> _reviews = [];
  LatLng? _selectedPoint;
  LatLng _currentPosition = LatLng(55.656707, 10.563214);
  LatLng? _userPosition;
  double _zoom = 7.0;
  MapController _mapController = MapController();
  List<SearchResults> _searchResults = [];
  final TextEditingController searchBarInput =TextEditingController(text: '');
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api.isLoggedIn(context).then((isLoggedIn) {
      if (!isLoggedIn || !mounted) return;

      _fetchFavorites();
      _fetchReviews();
    });
  }

  @override
  void dispose() {
    searchBarInput.dispose();
    super.dispose();
  }

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

  // Open location bottom menu
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
                // Location information
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                    const SizedBox(height: 10),
                    Text(description),
                  ],
                )),

                Column(children: [
                  // Toggle favorite button
                  IconButton(
                    icon: const Icon(Icons.star),
                    iconSize: 32,
                    color: _favorites.where((fav) => fav.lat == point.latitude && fav.lng == point.longitude).isEmpty ? Colors.grey : Colors.yellow,
                    onPressed: () => _toggleFavorite(point, name, description, setModalState, context)
                  ),

                  // View reviews button
                  IconButton(
                    icon: const Icon(Icons.rate_review),
                    iconSize: 32,
                    color: Colors.grey,
                    onPressed: () =>
                      Navigator.pushReplacementNamed(
                        context,
                        '/reviews',
                        arguments: ReviewList(_reviews.where((review) => review.lat == point.latitude && review.lng == point.longitude).toList(), Place(name, description, point))
                      ),
                  ),
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

  Future<void> _fetchReviews() async {
    final response = await api.request(context, api.ApiService.app, 'GET', '/reviews', null);
    if (response == null) return;

    final List<dynamic> reviews = jsonDecode(response);
    setState(() {
      _reviews = reviews.map((review) => Review.fromJson(review)).toList();
      debugPrint(_reviews.length.toString());
    });
  }

 Future<void> _onSearch() async {
  final http.Response response = await http.get(
    Uri.parse('https://nominatim.openstreetmap.org/search.php?q=${searchBarInput.text}&format=jsonv2'),
    headers: {'User-Agent': 'SkanTravels/1.0'}
  );

  final dynamic location = jsonDecode(response.body);

  // Move the map to the center of the first search result
  _mapController.move(
    LatLng(double.parse(location[0]['lat']), double.parse(location[0]['lon'])), 
    8
  );

  // Extract the bounding box and convert to LatLng
  final List<dynamic> boundingBox = location[0]['boundingbox'];

  _getOpenStreetMapData(LatLng(double.parse(boundingBox[0]), double.parse(boundingBox[2])), LatLng(double.parse(boundingBox[1]), double.parse(boundingBox[3])));
}

 Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission != LocationPermission.always || permission != LocationPermission.whileInUse){
    }
    else{
      await Geolocator.requestPermission();
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _mapController.move(LatLng(position.latitude, position.longitude), 10);
    setState(() {
      _userPosition = LatLng(position.latitude, position.longitude);
    });
    LatLngBounds bounds = _mapController.camera.visibleBounds;

    _getOpenStreetMapData(LatLng(bounds.southWest.latitude, bounds.southWest.longitude),LatLng(bounds.northEast.latitude, bounds.northEast.longitude));
  }

Future<void> _getOpenStreetMapData(LatLng southWest, LatLng northEast) async {

  final http.Response response;
      response = await http.get(
      Uri.parse('https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];node["tourism"="attraction"](${southWest.latitude},${southWest.longitude},${northEast.latitude},${northEast.longitude});out geom;'),
    );

  final parsed = jsonDecode(utf8.decode(response.bodyBytes));

  List<SearchResults> searchResults = parsed['elements']
      .where((element) => element['tags'] != null && element['tags']['name'] != null)
      .map<SearchResults>((json) => SearchResults.fromJson(json))
      .toList();

setState(() {
    _searchResults = searchResults;
  });
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
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition,
                initialZoom: _zoom,
                onTap: _onTap,
                onPositionChanged: (pos, _) => _zoom = pos.zoom,
              ),
              children: [
                openStreetMapTileLayer,
                  MarkerLayer(markers: [
                    if (_selectedPoint != null)
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
                    ),
                  if(_userPosition != null)
                  Marker(
                    point: _userPosition!,
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    child: const Icon(Icons.my_location, size: 15, color: Colors.blueAccent),
                    ),
                  ]),
                  ..._searchResults.map((point) => MarkerLayer(
                      markers: [
                        Marker(
                          point: point.location,
                          width: 30,
                          height: 50,
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                                IconButton(
                                icon: const Icon(Icons.location_pin, size: 30, color: Colors.red),
                                onPressed: () => _showLocation(point.location, point.name, ""),
                              ),
                            ],
                          )
                         
                        )
                      ],
                    )),
                    ..._reviews.map((review) => MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(review.lat, review.lng),
                          width: 30,
                          height: 50,
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              IconButton(
                                padding: const EdgeInsets.only(bottom: 10),
                                icon: const Icon(Icons.location_pin, size: 30, color:Colors.purpleAccent),
                                onPressed: () => _showLocation(LatLng(review.lat, review.lng), review.place_name, review.place_description),
                              ),
                              IconButton(
                                padding: const EdgeInsets.only(bottom: 10),
                                icon: const Icon(Icons.location_on_outlined, size: 30, color: Colors.purple),
                                onPressed: () => _showLocation(LatLng(review.lat, review.lng), review.place_name, review.place_description),
                              ),
                            ],
                          )
                        )
                      ],
                    )),
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
                              placeholder: 'Search city based',
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withOpacity(0.9),
                                boxShadow: const [BoxShadow(color: Color(0x20000000), offset: Offset(0, 1), blurRadius: 4)]
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 2, // Position the button at the bottom-right
                        bottom: 4.5,
                        child:
                          SizedBox(
                            width: 100,
                            height: 28,
                            child: ElevatedButton(
                              onPressed: () {
                                _onSearch();
                              },
                              child: const Text('Search'),
                            ),
                          ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
           Positioned(
            right: 2,
            bottom: 50,
            child:
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 48.0,
                      shadows: [BoxShadow(color: Color(0x20000000), offset: Offset(0, 1), blurRadius: 4)],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3),
                      child: IconButton(
                        icon: const Icon(
                          Icons.location_searching,
                          color: Colors.blue,
                          size: 28.0,
                        ),
                        onPressed: () {
                          _getCurrentLocation();
                        },
                      ),
                    ),
                  ],
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