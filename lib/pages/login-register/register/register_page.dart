// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:parkflow/components/style/designStyle.dart';
import 'package:parkflow/pages/home/home_page.dart';
import 'package:parkflow/pages/login-register/auth_services.dart';
import 'package:parkflow/pages/login-register/login/login_page.dart';
import 'package:parkflow/components/custom_button.dart';
import 'package:parkflow/components/custom_text_button.dart';
import 'package:parkflow/pages/login-register/register/services/email_service.dart';
//import van de services/widgets van register
import '../register/services/familyname_service.dart';
import '../register/services/name_service.dart';
import '../register/services/password_confirm_service.dart';
import '../register/services/password_service.dart';

///Beschrijving: Pagina om acounts te creeren en het in de database te zetten,
///deze pagina heeft een paar methodes om condities te controleren
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
  bool _areFieldsValid = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_checkPasswordStrength);
    emailController.addListener(_checkFormValidity);
    passwordController.addListener(_checkFormValidity);
    confirmPasswordController.addListener(_checkFormValidity);
    nameController.addListener(_checkFormValidity);
    familyNameController.addListener(_checkFormValidity);
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

//wachtwoord lengte controller
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

//controleer validatie voor de knop
  void _checkFormValidity() {
    setState(() {
      _areFieldsValid = emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty &&
          _passwordStrength != 'zwak' &&
          nameController.text.isNotEmpty;
    });
  }

//email validator:
  String? _emailValidator(String? value) {
    if (value == null || !value.contains('@') || !value.contains('.')) {
      return 'Ongeldige Email';
    }
    return null;
  }

//wachtwoord validator:
  String? _passwordValidator(String? value) {
    if (value == null || _passwordStrength == 'zwak') {
      return 'Zwakke Wachtwoord';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value != passwordController.text) {
      return 'wachtwoorden zijn niet gelijkt';
    }
    return null;
  }

//naam validator:
  String? _nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Naam is verwacht';
    }
    return null;
  }

//familie naam validator
  String? _familyNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Familie Naam is verwacht';
    }
    return null;
  }

//zet de user in de database methode op basis van mijn methode register Account.
  void _registerUser(BuildContext context) async {
    final name = nameController.text;
    final familyName = familyNameController.text;
    final result = await registerAccount(
      name: name,
      familyName: familyName,
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
      context: context,
    );

    if (result) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: NameTextField(
                          controller: nameController,
                          validator: _nameValidator),
                    ),
                    const SizedBox(width: padding),
                    Expanded(
                      child: FamilyNameTextField(
                        controller: familyNameController,
                        validator: _familyNameValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: verticalSpacing1),
                EmailTextField(
                  controller: emailController,
                  validator: _emailValidator,
                ),
                const SizedBox(height: verticalSpacing1),
                PasswordTextField(
                  controller: passwordController,
                  validator: _passwordValidator,
                ),
                const SizedBox(height: verticalSpacing1),
                ConfirmPasswordTextField(
                  controller: confirmPasswordController,
                  validator: _confirmPasswordValidator,
                ),
                const SizedBox(height: verticalSpacing2),
                Text('Wachtwoord sterkte: $_passwordStrength'),
                const SizedBox(height: verticalSpacing2),
                BlackButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _registerUser(context);
                    }
                  },
                  text: 'registreren',
                  color: _areFieldsValid ? null : Colors.grey,
                ),
                const SizedBox(height: verticalSpacing1),
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
                      text: 'log met je account ',
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
