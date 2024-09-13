import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/base/sidemenu.dart';
import 'models.dart' as models;
import 'api.dart' as api;

class ReviewListPage extends StatefulWidget {
  const ReviewListPage({super.key});

  @override
  State<ReviewListPage> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewListPage> {
  List<models.User> users = [];

  models.User? _getReviewUser(models.Review review) {
    return users.firstWhere((user) => user.id == review.userId);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    final arg = ModalRoute.of(context)!.settings.arguments as models.ReviewList;
    final reviews = arg.reviews;

    final userIds = reviews.map((review) => review.userId).toSet().toList();

    final response = await api.request(context, api.ApiService.auth, 'GET', '/api/Users/UsersByIds?userIds=' + userIds.join(','), null);
    if (response == null) return;

    debugPrint('response: ' + response);

    users = (jsonDecode(response) as List<dynamic>).map((user) => models.User.fromJson(user)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as models.ReviewList;
    final reviews = arg.reviews;
    final place = arg.place;

    return SideMenu(
      selectedIndex: -1,
      body: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: SingleChildScrollView(child: Container(
          decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20.0),
          child: Column(children:
            reviews.map((review) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x20000000),
                    offset: Offset(0,1),
                    blurRadius: 4,
                  ),
                ],
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(Icons.rate_review, color: Colors.purple, size: 36),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(review.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                        Text(review.content),
                        const SizedBox(height: 10),
                        if (review.image != null) Image.network(review.image!.imageUrl, height: 200),
                        if (review.image != null) const SizedBox(height: 15),
                        Row(children: [
                          for (var i = 0; i < review.rating; i++) const Icon(Icons.star, color: Colors.yellow),
                          for (var i = review.rating; i < 5; i++) const Icon(Icons.star_border),
                        ]),
                        const SizedBox(height: 10),
                        Text('Submitted by ' + (_getReviewUser(review)?.username ?? ''), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (!await api.isLoggedIn(context)) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must be logged in to do that")));
              return;
            }

            final review = await Navigator.pushNamed(context, '/create-review', arguments: place) as models.Review?;
            if (review != null) reviews.add(review);
          },
          backgroundColor: Colors.blue,
          focusColor: Colors.blueGrey,
          tooltip: "Write a Review",
          child: const Icon(CupertinoIcons.plus),
        ),
      ),
    );
  }
}