import 'package:flutter/material.dart';
import 'style/designStyle.dart' as style;

class SignOutButton extends StatelessWidget {
  const SignOutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => signOut(context),
      child: Text(
        'Uitloggen',
        style: TextStyle(fontSize: style.fontSize1),
      ),
    );
  }

  Future<void> signOut(BuildContext context) async {
    // update de locale data zodat het weet dat het uigelogd is, anders zieke buggs......
  }
}