// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/user/user_account.dart';
import '../../../model/user/user_logged_controller.dart';
import '../../../pages/home/home_page.dart';

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

Future<void> signin(BuildContext context, TextEditingController emailController,
    TextEditingController passwordController) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  final docSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(emailController.text.trim())
      .get();

  if (docSnapshot.exists) {
    final userData = docSnapshot.data();
    if (userData != null) {
      final user = UserAccount.fromJson(userData);
      final hashedPassword = hashPassword(passwordController.text.trim());

      if (user.password == hashedPassword) {
        //email bewaren =>
        final userModel = Provider.of<UserLogged>(context, listen: false);
        userModel.setEmail(emailController.text);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        Navigator.of(context).pop(); //verwijder de circular progress indicator.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mailadres of wachtwoord is onjuist'),
          ),
        );
      }
    } else {
      Navigator.of(context).pop(); //verwijder de circular progress indicator.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mailadres of wachtwoord is onjuist'),
        ),
      );
    }
  } else {
    Navigator.of(context).pop(); //verwijder de circular progress indicator.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('E-mailadres of wachtwoord is onjuist'),
      ),
    );
  }
}
