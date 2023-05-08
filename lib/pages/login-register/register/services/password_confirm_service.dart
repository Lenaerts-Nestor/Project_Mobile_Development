import 'package:flutter/material.dart';

class ConfirmPasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;

  const ConfirmPasswordTextField({Key? key, required this.controller, required this.validator}) : super(key: key);

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
