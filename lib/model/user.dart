// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';

class User_account {
  final String name;
  final String email;
  final String password;
  final String familiename;

  User_account({
    required this.familiename,
    required this.name,
    required this.email,
    required this.password,
  });

  //dit is om info te schrijven naar database
  Map<String, dynamic> tojson() => {
        'name': name,
        'email': email,
        'password': password,
        'familiename': familiename
      };

  //aanvragen informatie van de database.
  static User_account fromJson(Map<String, dynamic> json) => User_account(
      familiename: json['familiename'],
      name: json['name'],
      email: json['email'],
      password: json['password']);
}
