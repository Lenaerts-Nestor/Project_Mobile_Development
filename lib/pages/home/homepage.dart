import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkflow/components/navigationbar.dart';
import 'package:parkflow/pages/settings/settingsPage.dart';
import 'package:parkflow/pages/map/map.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  void navigationBottomBar(int newIndex) {
    setState(() {
      _selectedIndex = newIndex;
    });
  }

  final List<Widget> _pages = [
    //map page?
    MapPage(),
    //setting page?
    SettingsPage(),
    //nog extra pages ?
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: MyNavigationBar(
        onTabChange: (index) => navigationBottomBar(index),
      ),
    );
  }
}
