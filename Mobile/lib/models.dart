import 'dart:io';

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
  String profilePicture;
  DateTime createdAt;

  User( this.id, this.email, this.username, this.profilePicture, this.createdAt);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['email'],
      json['username'],
      json['profilePicture'],
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
