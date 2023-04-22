// ignore_for_file: camel_case_types

import 'package:parkflow/model/vehicle.dart';

class UserAccount {
  final String id;
  final String name;
  final String username;
  final String email;
  final String password;
  final String familyname;
  final List<Vehicle> vehicles;

  UserAccount({
    required this.id,
    required this.familyname,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    this.vehicles = const [],
  });

  Map<String, dynamic> toJson() => {
        'naam': name,
        'userNaam': username,
        'email': email,
        'password': password,
        'familieNaam': familyname,
        'vervoeren': vehicles.map((v) => v.toJson()).toList(),
        'id': id,
      };

  static UserAccount fromJson(Map<String, dynamic> json) => UserAccount(
        familyname: json['familieNaam'] as String? ?? '',
        name: json['naam'] as String? ?? '',
        username: json['userNaam'] as String? ?? '',
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
        id: json['id'] as String? ?? '',
        vehicles: json['vervoeren'] != null
            ? (json['vervoeren'] as List<dynamic>)
                .map((v) => Vehicle.fromJson(v))
                .toList()
            : [],
      );
}
