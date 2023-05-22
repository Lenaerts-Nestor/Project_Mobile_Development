// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:parkflow/components/style/designStyle.dart';
import 'package:parkflow/pages/login-register/auth_services.dart';
import 'package:parkflow/pages/login-register/login/forgot_password_page.dart';
import 'package:parkflow/pages/login-register/register/register_page.dart';
import 'package:parkflow/components/custom_button.dart';
import 'package:parkflow/components/custom_text_button.dart';
import 'package:parkflow/components/custom_text.dart';
import 'package:flutter_svg/svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
//validator gezet:
  String? _emailValidator(String? value) {
    if (value == null || !value.contains('@') || !value.contains('.')) {
      return 'Invalid email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(padding),
            //voor validators:
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: verticalSpacing2 * 2),
                  Center(
                    child: SvgPicture.asset(
                      'assets/logo.svg',
                      width: MediaQuery.of(context).size.width - padding * 3,
                    ),
                  ),
                  const SizedBox(height: verticalSpacing2 * 3),
                  const CustomText(
                    text: 'Parkeren was nog nooit zo eenvoudig',
                  ),
                  const SizedBox(height: verticalSpacing2),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextFormField(
                      controller: emailController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: _emailValidator,
                    ),
                  ),
                  const SizedBox(
                    height: verticalSpacing1,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextFormField(
                      controller: passwordController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Wachtwoord',
                      ),
                      obscureText: true,
                      validator: _passwordValidator,
                    ),
                  ),
                  const SizedBox(height: verticalSpacing2),
                  BlackButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        signin(context, emailController, passwordController);
                      }
                    },
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
