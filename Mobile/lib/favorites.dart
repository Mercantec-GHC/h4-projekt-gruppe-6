import 'dart:convert';
import 'api.dart' as api;
import 'package:flutter/material.dart';
import 'base/sidemenu.dart'; // Import the base layout widget
import 'models.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPage();
}

class _FavoritesPage extends State<FavoritesPage> {
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
        _favorites = favorites.map((favorite) => Favorite(favorite['id'], favorite['user_id'], favorite['lat'], favorite['lng'])).toList();
      });
    });

  }
  @override
  Widget build(BuildContext context) {
    return SideMenu(
      body: Container(
        decoration: BoxDecoration(color: Color(0xFFF9F9F9)),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(20.0),
        child: Column(children:
          _favorites.map((favorite) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x20000000),
                  offset: Offset(0, 1),
                  blurRadius: 4,
                ),
              ],
              color: Colors.white
            ),
            child: const Text("Favorite data here"),
          )).toList(),
        ),
      ),
    );
  }
}
