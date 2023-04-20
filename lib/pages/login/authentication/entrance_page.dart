import 'package:flutter/material.dart';
import 'package:parkflow/pages/home/home_page.dart';
import 'package:parkflow/pages/login/authentication/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class entrance_page extends StatefulWidget {
  const entrance_page({super.key});

  @override
  _entrance_pageState createState() => _entrance_pageState();
}

class _entrance_pageState extends State<entrance_page> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoggedInStatus();
  }

  Future<void> checkLoggedInStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _isLoggedIn ? HomePage() : LoginPage(),
      );
}
