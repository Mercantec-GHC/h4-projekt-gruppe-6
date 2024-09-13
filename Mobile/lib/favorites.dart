import 'dart:convert';
import 'services/api.dart' as api;
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

  void _confirmDeleteFavorite(Favorite favorite) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove favorite'),
          content: Text('Are you sure you want to remove ${favorite.name} from your favorites list?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () => _deleteFavorite(favorite), child: const Text('Remove', style: TextStyle(color: Colors.red))),
          ],
        );
      }
    );
  }

  void _deleteFavorite(Favorite favorite) async {
    Navigator.pop(context);

    if (await api.request(context, api.ApiService.app, 'DELETE', '/favorites/${favorite.id}', null) == null) {
      return;
    }

    setState(() {
      _favorites = _favorites.where((fav) => fav.id != favorite.id).toList();
    });
  }

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
      selectedIndex: 1,
      body: SingleChildScrollView(child: Container(
        decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(20.0),
        child: Column(children:
          _favorites.map((favorite) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 10),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(Icons.star, color: Colors.yellow, size: 36)
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(favorite.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                      Text(favorite.description),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(icon: const Icon(Icons.delete), color: Colors.grey, onPressed: () => _confirmDeleteFavorite(favorite)),
              ],
            ),
          )).toList(),
        ),
      ),
    ));
  }
}
