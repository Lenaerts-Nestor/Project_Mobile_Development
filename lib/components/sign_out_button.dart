// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'style/designStyle.dart' as myFontstyle;
import 'package:shared_preferences/shared_preferences.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => signOut(context),
      icon: const Icon(Icons.arrow_back),
      label: Text(
        'Log uit',
        style: TextStyle(fontSize: myFontstyle.fontSize1),
      ),
    );
  }

  Future<void> signOut(BuildContext context) async {
    // update de locale data zodat het weet dat het uigelogd is, anders zieke buggs......
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');

    // ga naar de login page =>
    Navigator.pushReplacementNamed(context, '/login');
  }
}
