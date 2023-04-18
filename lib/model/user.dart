// ignore_for_file: camel_case_types

import 'package:parkflow/model/vehicle.dart';

class User_account {
  final String id;
  final String name;
  final String email;
  final String wachtwoord;
  final String familiename;
  final List<Vehicle> vehicles;

  User_account({
    required this.id,
    required this.familiename,
    required this.name,
    required this.email,
    required this.wachtwoord,
    this.vehicles = const [],
  });

  Map<String, dynamic> toJson() => {
        'Naam': name,
        'Email': email,
        'wachtwoord': wachtwoord,
        'FamilieNaam': familiename,
        'Vervoeren': vehicles.map((v) => v.toJson()).toList(),
        'id': id,
      };

  static User_account fromJson(Map<String, dynamic> json) => User_account(
        familiename: json['FamilieNaam'] as String,
        name: json['Naam'] as String,
        email: json['Email'] as String,
        wachtwoord: json['wachtwoord'] as String,
        id: json['id'],
        vehicles: (json['Vervoeren'] as List<dynamic>)
            .map((v) => Vehicle.fromJson(v))
            .toList(),
      );
}
