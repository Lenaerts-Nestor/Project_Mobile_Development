import 'package:flutter/material.dart';
import 'style/designStyle.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double maxWidth;

  const CustomText({
    Key? key,
    required this.text,
    this.maxWidth = 500, // default value is infinite width
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Text(
        text,
        style: TextStyle(
          color: color2,
          fontSize: fontSize2,
        ),
      ),
    );
  }
}
