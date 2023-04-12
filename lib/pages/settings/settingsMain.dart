// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:parkflow/pages/settings/pages/profielPage.dart';
import '../../components/signOutComp.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfielPage(),
                  ),
                );
              },
              child: const Text('Profiel'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Button 2'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Button 3'),
            ),
            const SizedBox(height: 50),
            const SignOutButton()
          ],
        ),
      ),
    );
  }
}
