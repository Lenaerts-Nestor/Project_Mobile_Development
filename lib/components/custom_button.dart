import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final double height;
  final double width;
  final VoidCallback onPressed;
  final Color? textColor;
  final Color? backgroundColor;

  const CustomButton({
    Key? key,
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
    this.textColor,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.toDouble(),
      width: width.toDouble(),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
        ),
        child: Text(
          label,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
