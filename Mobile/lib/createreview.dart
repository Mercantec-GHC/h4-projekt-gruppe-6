import 'package:flutter/material.dart';
import 'package:mobile/base/sidemenu.dart';
import 'models.dart';

class CreateReviewPage extends StatefulWidget {
  const CreateReviewPage({super.key});

  @override
  State<CreateReviewPage> createState() => _CreateReviewState();

}

class _CreateReviewState extends State<CreateReviewPage> {
  @override
  Widget build(BuildContext context) {
    final place = ModalRoute.of(context)!.settings.arguments as Place;

    return SideMenu(
      selectedIndex: -1,
      body: Scaffold(
        body: SingleChildScrollView(child: Container(
          decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Text(place.description, style: const TextStyle(color: Colors.grey))
          ]),


        ))
      )
    );
  }
}