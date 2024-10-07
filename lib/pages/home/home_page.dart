// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:parkflow/components/navigationbar.dart';
import 'package:parkflow/pages/map/map_page.dart';
import 'package:parkflow/pages/settings/settingsMain.dart';

import '../info/infoPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

    //nog extra pages ?
    InfoPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: MyNavigationBar(
        onTabChange: (index) => navigationBottomBar(index),
      ),
    );
  }
}
