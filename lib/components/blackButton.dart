import 'package:flutter/material.dart';
import 'style/designStyle.dart' as style;

class BlackButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const BlackButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 60,
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: style.fontSize3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
