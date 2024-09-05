import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/base/sidemenu.dart';
import 'models.dart';

class ReviewListPage extends StatefulWidget {
  const ReviewListPage({super.key});

  @override
  State<ReviewListPage> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewListPage> {
  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as ReviewList;
    final reviews = arg.reviews;
    final place = arg.place;

    return SideMenu(
      selectedIndex: -1,
      body: Scaffold(
        backgroundColor: Color(0xFFF9F9F9),
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
                    child: Icon(Icons.radio, color: Colors.purple, size: 36),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(review.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                        Text(review.content),
                        const SizedBox(height: 10),
                        Row(children: [
                          for (var i = 0; i < review.rating; i++) const Icon(Icons.star, color: Colors.yellow),
                          for (var i = review.rating; i < 5; i++) const Icon(Icons.star_border),
                        ]),
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
            final review = await Navigator.pushNamed(context, '/create-review', arguments: place) as Review?;
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