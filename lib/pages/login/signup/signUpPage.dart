import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../model/user.dart';

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
  final nameController = TextEditingController();
  final familyNameController = TextEditingController();

  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    familyNameController.dispose();

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
            _buildTextField(nameController, 'Name', TextInputAction.next),
            const SizedBox(height: 20),
            _buildTextField(
                familyNameController, 'Family Name', TextInputAction.next),
            const SizedBox(height: 20),
            _buildTextField(emailController, 'Email', TextInputAction.next),
            const SizedBox(height: 10),
            _buildTextField(
                passwordController, 'Password', TextInputAction.done,
                obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'Create account',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () {
                final name = nameController.text;
                final familyName = familyNameController.text;

                signUp(name: name, familyName: familyName);
              },
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 20),
                text: 'Already have an account? ',
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.onClickedSignIn,
                    text: 'Sign Up',
                    style: const TextStyle(color: Colors.amber),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      TextInputAction action,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      textInputAction: action,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      obscureText: obscureText,
    );
  }

  Future signUp({
    required String name,
    required String familyName,
  }) async {
    //lading screen, niet aanraken
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final firebaseUser = FirebaseAuth.instance.currentUser;
      final docUser =
          FirebaseFirestore.instance.collection('users').doc(firebaseUser!.uid);
      final user = User_account(
        id: docUser.id,
        name: name,
        familiename: familyName,
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      //convereteren naar json
      final json = user.toJson();
      //creer document en schrijf het op firebase collection
      await docUser.set(json);

      //om errors laad error te voorkomen =>
      if (_isMounted) {
        //sluit de progress dialoog en terug gaan
        Navigator.of(context).pop();

        // toon message dat het gelukt is
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Nieuw: controleer of de widget nog gemount is voordat u de context gebruikt
      //om errors laad error te voorkomen =>
      if (_isMounted) {
        // sluit de progress dialoog als het niet gelukt is
        Navigator.of(context).pop();

        //toon errors op basis van de situatie =>
        String errorMessage;
        if (e.code == 'email-already-in-use') {
          errorMessage = 'The email address is already in use';
        } else {
          errorMessage = 'An error occurred, please try again';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      //print het op de terminal.
      print(e);
      return;
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
