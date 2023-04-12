// ignore_for_file: camel_case_types

class User_account {
  final String id;
  final String name;
  final String email;
  final String password;
  final String familiename;

  User_account({
    required this.id,
    required this.familiename,
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'familiename': familiename,
        'id': id,
      };

  static User_account fromJson(Map<String, dynamic> json) => User_account(
        familiename: json['familiename'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
        id: json['id'],
      );
}
