// ignore_for_file: must_be_immutable

import 'style/designStyle.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyNavigationBar extends StatelessWidget {
  void Function(int)? onTabChange;
  MyNavigationBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.only(left: 0.0),
        child: GNav(
          
          onTabChange: (value) => onTabChange!(value),
          activeColor: color6,
          backgroundColor: color2,
          color: color4,
          gap: 8,
          tabs: const [
            GButton(
              icon: Icons.map,
              iconSize: iconSizeNav,
            ),
            GButton(
              icon: Icons.favorite,
              iconSize: iconSizeNav,
            ),
            GButton(
              icon: Icons.directions_car_outlined,
              iconSize: iconSizeNav,
            ),
            GButton(
              icon: Icons.settings,
              iconSize: iconSizeNav,
            ),
          ],
        ),
      ),
    );
  }
}
