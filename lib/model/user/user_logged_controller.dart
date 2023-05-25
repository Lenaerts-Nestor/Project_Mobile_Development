import 'package:flutter/material.dart';

///korte Beschrijving: houd bij als de user ingelogd is.
/// we sturen de email terug, de email = de [Document_ID] bij [Firestore]. 
class UserLogged with ChangeNotifier {
  String _email = '';

  String get email => _email;

  void setEmail(String newEmail) {
    _email = newEmail;
    notifyListeners();
  }
}
