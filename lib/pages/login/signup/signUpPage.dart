import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

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
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final familyNameController = TextEditingController();

  String _passwordStrength = '';

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_checkPasswordStrength);
  }

  //source: https://stackoverflow.com/questions/59558604/why-do-we-use-the-dispose-method-in-flutter-dart-code.
  //Deze methode ruimt de geheugenruimte op die door de tekstveldcontrollers wordt gebruikt wanneer het widget wordt vernietigd, om te voorkomen dat geheugen lekt.
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    familyNameController.dispose();
    super.dispose();
  }

  //nodig om te kijken als de password is niet te klein. /laat het in engles staan.
  void _checkPasswordStrength() {
    final length = passwordController.text.length;
    setState(() {
      if (length < 6) {
        _passwordStrength = 'zwak';
      } else if (length < 12) {
        _passwordStrength = 'medium';
      } else {
        _passwordStrength = 'goed';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField(nameController, 'Naam', TextInputAction.next),
            const SizedBox(height: 20),
            _buildTextField(
                familyNameController, 'Familie Naam', TextInputAction.next),
            const SizedBox(height: 20),
            _buildTextField(emailController, 'Email', TextInputAction.next),
            const SizedBox(height: 10),
            _buildTextField(
                passwordController, 'Wachtwoord', TextInputAction.next,
                obscureText: true),
            const SizedBox(height: 10),
            Text('Wachtwoord sterkte: $_passwordStrength'),
            const SizedBox(height: 10),
            _buildTextField(confirmPasswordController, 'Bevestig Wachtwoord',
                TextInputAction.done,
                obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'Creeër account',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: _passwordStrength == 'zwak'
                  ? null
                  : () {
                      final name = nameController.text;
                      final familyName = familyNameController.text;

                      signUp(name: name, familyName: familyName);
                    },
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 20),
                text: 'heb je al een account? ',
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.onClickedSignIn,
                    text: 'Log In',
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
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wachtwoorden komen niet overeen')),
      );
      return;
    }

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
        wachtwoord: passwordController.text.trim(),
      );

      final json = user.toJson();
      await docUser.set(json);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account is aangemaakt met succes')),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();

      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'deze email is al in gebruik.';
      } else {
        errorMessage = 'er is een error, probeer opnieuw';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      print(e);
      return;
    }
  }
}
