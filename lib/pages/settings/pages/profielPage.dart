// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfielPage extends StatefulWidget {
  const ProfielPage({super.key});

  @override
  State<ProfielPage> createState() => _ProfielPageState();
}

class _ProfielPageState extends State<ProfielPage> {
  @override
  Widget build(BuildContext context) {
    late final user = FirebaseAuth.instance.currentUser!;
    return Center(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
