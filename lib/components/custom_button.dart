// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;
  final Color? color;

  const CustomButton({
    Key? key,
    required this.label,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: color,
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
