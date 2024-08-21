import 'package:flutter/material.dart';
import 'base/sidemenu.dart'; // Import the base layout widget

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SideMenu(
      body: Center(
        child: Text('This is Page 1'),
      ),
    );
  }
}
