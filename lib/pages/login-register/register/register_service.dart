// ignore_for_file: use_build_context_synchronously, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:parkflow/model/user/user_account.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';
import 'package:parkflow/pages/home/home_page.dart';
import 'package:provider/provider.dart';

class Register_Service {
  static Future<bool> registerAccount({
    required String name,
    required String familyName,
    required String email,
    required String password,
    required BuildContext context,
    required String confirmPassword,
  }) async {
    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wachtwoord moet minstens 6 karakters lang zijn'),
        ),
      );
      return false;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wachtwoorden komen niet overeen')),
      );
      return false;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      final docUser = FirebaseFirestore.instance.collection('users').doc(email);
      final docSnapshot = await docUser.get();
      if (docSnapshot.exists) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deze e-mail is al geregistreerd.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      final hashedPassword = hashPassword(password.trim());

      final user = UserAccount(
        id: docUser.id,
        name: name,
        familyname: familyName,
        email: email.trim(),
        password: hashedPassword,
        username: '',
      );

      final json = user.toJson();
      await docUser.set(json);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account is aangemaakt met succes')),
      );
      final userModel = Provider.of<UserLogged>(context, listen: false);
      userModel.setEmail(email);
      return true;
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Er is een fout opgetreden. Probeer opnieuw.'),
          backgroundColor: Colors.red,
        ),
      );
      print(e);
      return false;
    }
  }

  static Future<void> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(email).get();

    if (docSnapshot.exists) {
      final userData = docSnapshot.data();
      if (userData != null) {
        final user = UserAccount.fromJson(userData);
        final hashedPassword = hashPassword(password.trim());

        if (user.password == hashedPassword) {
          final userModel = Provider.of<UserLogged>(context, listen: false);
          userModel.setEmail(email);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else {
          Navigator.of(context)
              .pop(); // Remove the circular progress indicator.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('E-mailadres of wachtwoord is onjuist'),
            ),
          );
        }
      } else {
        Navigator.of(context).pop(); // Remove the circular progress indicator.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mailadres of wachtwoord is onjuist'),
          ),
        );
      }
    } else {
      Navigator.of(context).pop(); // Remove the circular progress indicator.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mailadres of wachtwoord is onjuist'),
        ),
      );
    }
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
