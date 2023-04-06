import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => FirebaseAuth.instance.signOut(),
      icon: const Icon(Icons.arrow_back),
      label: const Text(
        'Sign Out',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
