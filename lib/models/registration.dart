// To parse this JSON data, do
//
//     final registration = registrationFromJson(jsonString);

import 'dart:convert';

Registration registrationFromJson(String str) =>
    Registration.fromJson(json.decode(str));

String registrationToJson(Registration data) => json.encode(data.toJson());

class Registration {
  final String username;
  final String email;
  final String password;

  Registration({
    required this.username,
    required this.email,
    required this.password,
  });

  factory Registration.fromJson(Map<String, dynamic> json) => Registration(
        username: json["username"],
        email: json["email"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "email": email,
        "password": password,
      };
}
