import 'package:latlong2/latlong.dart';

class Favorite {
  int id;
  String userId;
  double lat;
  double lng;
  String name;
  String description;

  Favorite(this.id, this.userId, this.lat, this.lng, this.name, this.description);

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      json['id'],
      json['user_id'],
      json['lat'],
      json['lng'],
      json['name'],
      json['description'],
    );
  }
}

class Review {
  int id;
  String userId;
  double lat;
  double lng;
  String place_name;
  String place_description;
  String title;
  String content;
  int rating;

  Review(this.id, this.userId, this.lat, this.lng, this.place_name, this.place_description, this.title, this.content, this.rating);

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      json['id'],
      json['user_id'],
      json['lat'],
      json['lng'],
      json['place_name'],
      json['place_description'],
      json['title'],
      json['content'],
      json['rating'],
    );
  }
}

class Place {
  String name;
  String description;

  Place(this.name, this.description);
}

class ReviewList {
  List<Review> reviews;
  Place place;

  ReviewList(this.reviews, this.place);
}

class Login {
  String token;
  String id;
  String refreshToken;

  Login(this.token, this.id, this.refreshToken);

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      json['token'],
      json['id'],
      json['refreshToken'],
    );
  }
}

class User {
  String id;
  String email;
  String username;
  DateTime createdAt;

  User( this.id, this.email, this.username, this.createdAt);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['email'],
      json['username'],
      DateTime.parse(json['createdAt']),
    );
  }
}

class SearchResults{
  LatLng location;
  String name;
  String description;

SearchResults(this.location, this.name, this.description);
}
