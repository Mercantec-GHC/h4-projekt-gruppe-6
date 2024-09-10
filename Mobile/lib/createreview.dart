import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/base/sidemenu.dart';
import 'models.dart';
import 'api.dart' as api;

class CreateReviewPage extends StatefulWidget {
  const CreateReviewPage({super.key});

  @override
  State<CreateReviewPage> createState() => _CreateReviewState();

}

class _CreateReviewState extends State<CreateReviewPage> {
  final titleInput = TextEditingController();
  final contentInput = TextEditingController();
  Place? place;
  var rating = 0;
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    place = ModalRoute.of(context)!.settings.arguments as Place;

    return SideMenu(
      selectedIndex: -1,
      body: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(40),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(children: [
                Text(place!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                Text(place!.description, style: const TextStyle(color: Colors.grey)),
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
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed: _pickImageFromGallery, icon: const Icon(Icons.image, color: Colors.grey), tooltip: "Pick an image from your gallery",),
                    IconButton(onPressed: _pickImageFromCamera, icon: const Icon(Icons.camera_alt, color: Colors.grey), tooltip: "Take a picture with your camera",),
                  ],
                ),


                // Review Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < rating; i++) IconButton(onPressed: () => setState(() => rating = i+1), icon: const Icon(Icons.star, color: Colors.yellow)),
                    for (var i = rating; i < 5; i++) IconButton(onPressed: () => setState(() => rating = i+1), icon: const Icon(Icons.star_border)),
                  ],
                ),

                const SizedBox(height: 30),
                ElevatedButton(onPressed: _submitReview, child: const Text('Submit Review')),
              ]),
            )
          )
        )
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    titleInput.dispose();
    contentInput.dispose();
  }
  Future _pickImageFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  Future _pickImageFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  Future<void> _submitReview() async {
    final response = await api.request(context, api.ApiService.app, 'POST', '/reviews', {
      'title': titleInput.text,
      'content': contentInput.text,
      'place_name': place!.name,
      'place_description': place!.description,
      'rating': rating,
      'lat': place!.point.latitude,
      'lng': place!.point.longitude,
    });

    if (response == null || !mounted) return;

    final review = Review.fromJson(jsonDecode(response));

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted')));

    Navigator.pop(context, review);
  }
}