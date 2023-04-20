// ignore_for_file: camel_case_types

import 'package:parkflow/model/vehicle.dart';

class UserAcount {
  final String id; //moet unique zijn
  final String name;
  final String email;
  final String password;
  final String familyname;
  final List<Vehicle> vehicles;

  UserAcount({
    required this.id,
    required this.familyname,
    required this.name,
    required this.email,
    required this.password,
    this.vehicles = const [],
  });

  Map<String, dynamic> toJson() => {
        'Naam': name,
        'Email': email,
        'password': password,
        'FamilieNaam': familyname,
        'Vervoeren': vehicles.map((v) => v.toJson()).toList(),
        'id': id,
      };

  static UserAcount fromJson(Map<String, dynamic> json) => UserAcount(
        familyname: json['FamilieNaam'] as String,
        name: json['Naam'] as String,
        email: json['Email'] as String,
        password: json['password'] as String,
        id: json['id'],
        vehicles: (json['Vervoeren'] as List<dynamic>)
            .map((v) => Vehicle.fromJson(v))
            .toList(),
      );
}
