import 'package:flutter/material.dart';
import 'package:parkflow/components/style/designStyle.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final IconData? icon;
  final VoidCallback? onPressed;
  final String titleText;
  final Color backgroundcolor;
  final double marginleft;

  const MyAppBar({
    Key? key,
    this.icon,
    this.onPressed,
    required this.titleText,
    required this.backgroundcolor,
    required this.marginleft,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          icon,
          color: Colors.white,
        ),
        onPressed: onPressed,
      ),
      title: Container(
        margin: EdgeInsets.only(left: marginleft),
        child: Text(
          titleText,
          style: const TextStyle(fontSize: fontSize3),
        ),
      ),
      backgroundColor: backgroundcolor,
      elevation: 0.0,
    );
  }
}
