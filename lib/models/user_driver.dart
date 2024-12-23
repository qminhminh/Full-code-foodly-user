// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

List<UserDriver> driversFromJson(String str) =>
    List<UserDriver>.from(json.decode(str).map((x) => UserDriver.fromJson(x)));

String driversToJson(List<UserDriver> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserDriver {
  final String id;
  final String username;
  final String email;
  final bool verification;
  final String phone;
  final bool phoneVerification;
  final String userType;
  final String profile;

  UserDriver({
    required this.id,
    required this.username,
    required this.email,
    required this.verification,
    required this.phone,
    required this.phoneVerification,
    required this.userType,
    required this.profile,
  });

  factory UserDriver.fromJson(Map<String, dynamic> json) => UserDriver(
        id: json["_id"],
        username: json["username"],
        email: json["email"],
        verification: json["verification"],
        phone: json["phone"],
        phoneVerification: json["phoneVerification"],
        userType: json["userType"],
        profile: json["profile"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "username": username,
        "email": email,
        "verification": verification,
        "phone": phone,
        "phoneVerification": phoneVerification,
        "userType": userType,
        "profile": profile,
      };
}
