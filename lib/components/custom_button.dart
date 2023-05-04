import 'package:flutter/material.dart';
import 'style/designStyle.dart';

class BlackButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isRed;

  const BlackButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isRed = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isRed ? color6 : color7;

    return SizedBox(
      width: 200,
      height: 60,
      child: Material(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundColor,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: color1,
                fontSize: fontSize3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
