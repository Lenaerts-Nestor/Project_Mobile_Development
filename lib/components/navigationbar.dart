// ignore_for_file: must_be_immutable

import 'style/designStyle.dart' as style;
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
          activeColor: style.color6,
          backgroundColor: style.color2,
          color: style.color4,
          gap: 8,
          tabs: const [
            GButton(
              icon: Icons.map,
              iconSize: style.iconSizeNav,
            ),
            GButton(
              icon: Icons.favorite,
              iconSize: style.iconSizeNav,
            ),
            GButton(
              icon: Icons.directions_car_outlined,
              iconSize: style.iconSizeNav,
            ),
            GButton(
              icon: Icons.settings,
              iconSize: style.iconSizeNav,
            ),
          ],
        ),
      ),
    );
  }
}
