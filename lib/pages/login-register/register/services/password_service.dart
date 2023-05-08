import 'package:flutter/material.dart';

class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;

  const PasswordTextField(
      {Key? key, required this.controller, required this.validator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Wachtwoord',
      ),
      obscureText: true,
      validator: validator,
    );
  }
}
