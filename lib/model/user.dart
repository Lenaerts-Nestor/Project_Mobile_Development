// ignore_for_file: camel_case_types

import 'package:parkflow/model/vehicle.dart';

class User_account {
  final String id;
  final String name;
  final String email;
  final String password;
  final String familiename;
  final List<Vehicle> vehicles;

  User_account({
    required this.id,
    required this.familiename,
    required this.name,
    required this.email,
    required this.password,
    this.vehicles = const [],
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'familiename': familiename,
        'vehicles': vehicles.map((v) => v.toJson()).toList(),
        'id': id,
      };

  static User_account fromJson(Map<String, dynamic> json) => User_account(
        familiename: json['familiename'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
        id: json['id'],
        vehicles: (json['vehicles'] as List<dynamic>)
            .map((v) => Vehicle.fromJson(v))
            .toList(),
      );
}
