import 'package:flutter/material.dart';
import 'package:mobile/base/sidemenu.dart';
import 'models.dart';

class CreateReviewPage extends StatefulWidget {
  const CreateReviewPage({super.key});

  @override
  State<CreateReviewPage> createState() => _CreateReviewState();

}

class _CreateReviewState extends State<CreateReviewPage> {
  final titleInput = TextEditingController();
  final contentInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final place = ModalRoute.of(context)!.settings.arguments as Place;

    return SideMenu(
      selectedIndex: -1,
      body: Scaffold(
        backgroundColor: Color(0xFFF9F9F9),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(40),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(children: [
                Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                Text(place.description, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 50),
                TextField(
                  controller: titleInput,
                  enableSuggestions: true,
                  autocorrect: true,
                  decoration: const InputDecoration(
                    hintText: 'Review Title',
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: contentInput,
                  minLines: 5,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Write a review...',
                  )
                )
              ]),
            )
          )
        )
      )
    );
  }

  @override
  void dispose() {
    titleInput.dispose();
    contentInput.dispose();
  }
}