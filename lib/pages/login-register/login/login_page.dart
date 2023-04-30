// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:parkflow/pages/login-register/auth_services.dart';

import '../../../pages/login-register/login/forgot_password_page.dart';
import '../../../pages/login-register/register/register_page.dart';
import 'package:parkflow/components/custom_button.dart'; //test
import 'package:parkflow/components/custom_text_button.dart'; //test

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
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
    return Scaffold(
      body: SafeArea(
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
              BlackButton(
                onPressed: () =>
                    signin(context, emailController, passwordController),
                text: 'inloggen',
              ),
              CustomTextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage(),
                    ),
                  );
                },
                text: 'Wachtwoord resetten',
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('geen account?'),
                  CustomTextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()),
                      );
                    },
                    text: 'Maak een account',
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
