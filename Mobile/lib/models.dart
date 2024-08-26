class Favorite {
  int id;
  String userId;
  double lat;
  double lng;

  Favorite(this.id, this.userId, this.lat, this.lng);
}

class Login {
  String token;
  String id;

  Login(this.token, this.id);

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      json['token'],
      json['id'],
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
