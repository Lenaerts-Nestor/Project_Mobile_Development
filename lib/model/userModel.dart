// ignore_for_file: file_names

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

  Map<String, dynamic> tojson() =>
      {'id': id, 'name': name, 'email': email, 'password': password};
}
