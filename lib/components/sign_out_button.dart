// ignore_for_file: use_build_context_synchronously, library_prefixes

import 'package:flutter/material.dart';

import 'style/designStyle.dart' as myFontstyle;

class SignOutButton extends StatelessWidget {
  const SignOutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => signOut(context),
      icon: const Icon(Icons.arrow_back),
      label: Text(
        'Log uit',
        style: TextStyle(fontSize: myFontstyle.fontSize1),
      ),
    );
  }

  Future<void> signOut(BuildContext context) async {
    // update de locale data zodat het weet dat het uigelogd is, anders zieke buggs......
  }
}

//DEPRICATED !!!
//SEE NEW BLACK BUTTON
