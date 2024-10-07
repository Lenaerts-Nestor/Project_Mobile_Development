import 'package:flutter/material.dart';

class ConfirmPasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;

  const ConfirmPasswordTextField({super.key, required this.controller, required this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'Bevestig Wachtwoord',
      ),
      obscureText: true,
      validator: validator,
    );
  }
}
