import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyNavigationBar extends StatelessWidget {
  void Function(int)? onTabChange;
  MyNavigationBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.0),
      child: GNav(
        onTabChange: (value) => onTabChange!(value),
        activeColor: Colors.cyan[300],
        tabActiveBorder: Border.all(color: Colors.black),
        gap: 8,
        tabs: const [
          GButton(
            icon: Icons.map,
            text: 'Map',
          ),
          GButton(
            icon: Icons.favorite,
            text: 'Favoriet',
          ),
          GButton(
            icon: Icons.directions_car_outlined,
            text: 'Parking',
          ),
          GButton(
            icon: Icons.settings,
            text: 'Settings',
          ),
        ],
      ),
    );
  }
}
