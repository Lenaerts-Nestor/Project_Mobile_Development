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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: verticalSpacing2*2),
                Center(
                  child: SvgPicture.asset(
                    'assets/logo.svg',
                    width: MediaQuery.of(context).size.width - padding*3,
                  ),
                ),
                const SizedBox(height: verticalSpacing2*3),
                const CustomText(
                  text: 'Parkeren was nog nooit zo eenvoudig',
                ),
                const SizedBox(height: verticalSpacing2),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                ),
                const SizedBox(
                  height: verticalSpacing1,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: passwordController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Wachtwoord',
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: verticalSpacing2),
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
    );
  }
}
