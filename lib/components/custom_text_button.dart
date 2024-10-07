import 'package:flutter/material.dart';
import 'style/designStyle.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: color5,
          fontSize: fontSize1,
        ),
      ),
    );
  }
}
