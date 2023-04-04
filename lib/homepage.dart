import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parkflow/login.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key, required this.user}) : super(key: key);

  final User? user;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text('Welcome, ${widget.user!.email}!'),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _signOut,
              child: const Text('Sign out'),
            ),
          ),
        ],
      ),
    );
  }
}
