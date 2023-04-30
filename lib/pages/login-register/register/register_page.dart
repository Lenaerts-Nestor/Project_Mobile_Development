// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:parkflow/pages/home/home_page.dart';
import 'package:parkflow/pages/login-register/auth_services.dart';
import 'package:parkflow/pages/login-register/login/login_page.dart';
import 'package:parkflow/components/custom_button.dart'; //test
import 'package:parkflow/components/custom_text_button.dart'; //test

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

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
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                        nameController, 'Naam', TextInputAction.next,
                        obscureText: false),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildTextField(
                      familyNameController,
                      'Familie Naam',
                      TextInputAction.next,
                      obscureText: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(emailController, 'Email', TextInputAction.next,
                  obscureText: false),
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
              BlackButton(
                onPressed: _passwordStrength == 'zwak'
                    ? null
                    : () async {
                        final name = nameController.text;
                        final familyName = familyNameController.text;
                        final result = await registerAccount(
                          name: name,
                          familyName: familyName,
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                          confirmPassword:
                              confirmPasswordController.text.trim(),
                          context: context,
                        );

                        if (result) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        }
                      },
                text: 'registreren',
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('al een account?'),
                  CustomTextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    text: 'log hier in',
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    TextInputAction textInputAction, {
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      obscureText: obscureText,
    );
  }
}
