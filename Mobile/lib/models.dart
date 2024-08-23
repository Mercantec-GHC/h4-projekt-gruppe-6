class Favorite {
  int id;
  String userId;
  double lat;
  double lng;

  Favorite(this.id, this.userId, this.lat, this.lng);
}

class User {
  String token;
  String id;
  String email;
  String username;
  DateTime createdAt;

  User(this.token, this.id, this.email, this.username, this.createdAt);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['token'],
      json['id'],
      json['email'],
      json['username'],
      DateTime.parse(json['createdAt']),
    );
  }
}

