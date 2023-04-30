import 'package:flutter/material.dart';
import 'style/designStyle.dart' as style;

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: style.color5,
          fontSize: style.fontSize1,
        ),
      ),
    );
  }
}
