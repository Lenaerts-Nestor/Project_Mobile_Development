import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:parkflow/pages/login/signIn/login_page.dart';

import '../../../model/user_account.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    Key? key,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<RegisterPage> {
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    familyNameController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField(nameController, 'Naam', TextInputAction.next),
              const SizedBox(height: 20),
              Row(
                children: [],
              ),
              _buildTextField(
                  familyNameController, 'Familie Naam', TextInputAction.next),
              const SizedBox(height: 20),
              _buildTextField(emailController, 'Email', TextInputAction.next),
              const SizedBox(height: 10),
              _buildTextField(
                  passwordController, 'Wachtwoord', TextInputAction.next,
                  obscureText: true),
              const SizedBox(height: 10),
              _buildTextField(confirmPasswordController, 'Bevestig Wachtwoord',
                  TextInputAction.done,
                  obscureText: true),
              const SizedBox(height: 10),
              Text('Wachtwoord sterkte: $_passwordStrength'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('geen account ? '),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: const Text('creer account'))
                ],
              ),
            ],
          ),
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
      final user = UserAccount(
        id: docUser.id,
        name: name,
        familyname: familyName,
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        username: '',
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
