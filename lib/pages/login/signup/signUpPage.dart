// ignore_for_file: file_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../model/user.dart';

//bekijk authentication om te kijken welke mails zijn al bezet...........

class SignUpPage extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUpPage({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final namecontroller = TextEditingController();
  final familienamecontroller = TextEditingController();

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
            TextField(
              controller: namecontroller,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: familienamecontroller,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'FamilieName',
              ),
            ),
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
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'Create account',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () {
                final name = namecontroller.text;
                final familiename = familienamecontroller.text;

                signUp(name: name, familiename: familiename);
              },
            ),
            const SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 20),
                text: 'Alreadry have an account?  ',
                children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignIn,
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

  Future signUp({
    required String name,
    required String familiename,
  }) async {
    //lading screen, niet aanraken
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    //account aanmaken
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());

      //als het aanmaken van account lukt gebuert er de volgende =>

      final firebaseUser = FirebaseAuth.instance.currentUser;

      //referentie naar document in firebase.
      final docUser =
          FirebaseFirestore.instance.collection('users').doc(firebaseUser!.uid);

      //informatie creeren
      final user = User_account(
        id: docUser.id,
        name: name,
        familiename: familiename,
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      //converteren naar json
      final json = user.toJson();
      //creer document en schrijf het op firebase collection.
      await docUser.set(json);
    } on FirebaseException catch (e) {
      print(e);
      return;
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
    //dit zorgt dat de lading screen niet blijft hangen, NIET AANRAKEN
  }
}
