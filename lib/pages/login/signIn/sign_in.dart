// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:parkflow/pages/login/signIn/forgot_password_page.dart';

import '../../../main.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onClickSignUp;

  const LoginPage({
    Key? key,
    required this.onClickSignUp,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: passwordController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Wachtwoord',
              ),
              obscureText: true,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton.icon(
              onPressed: signin,
              icon: const Icon(Icons.login),
              label: const Text(
                'Log in',
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            GestureDetector(
              child: const Text(
                'Wachtwoord resetten',
                style: TextStyle(color: Colors.blue, fontSize: 20),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordPage(),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 20),
                text: 'No account?  ',
                children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickSignUp,
                      text: 'Sign Up',
                      style: const TextStyle(color: Colors.amber))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> signin() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      //lading screen, niet aanraken
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('E-mailadres of wachtwoord is onjuist'),
          ),
        );
      } else {
        print(e);
      }
    } catch (e) {
      print(e);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
     //dit zorgt dat de lading screen niet blijft hangen, NIET AANRAKEN
  }
}
