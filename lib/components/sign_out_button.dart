// sign_out_button.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'style/designStyle.dart' as myFontstyle;

class SignOutButton extends StatelessWidget {
  const SignOutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => FirebaseAuth.instance.signOut(),
      icon: const Icon(Icons.arrow_back),
      label: Text(
        'Sign Out',
        style: TextStyle(fontSize: myFontstyle.fontSize1),
      ),
    );
  }
}
