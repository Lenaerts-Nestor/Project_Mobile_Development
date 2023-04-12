// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';

class User_account {
  String id;
  final String name;
  final String email;
  final String password;

  User_account({
    this.id = '',
    required this.name,
    required this.email,
    required this.password,
  });

  //dit is om info te schrijven naar database
  Map<String, dynamic> tojson() =>
      {'id': id, 'name': name, 'email': email, 'password': password};

  //aanvragen informatie van de database.
  static User_account fromJson(Map<String, dynamic> json) => User_account(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password']);
}
