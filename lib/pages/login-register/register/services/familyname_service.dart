import 'package:flutter/material.dart';

class FamilyNameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;

  const FamilyNameTextField(
      {super.key, required this.controller, required this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Familienaam',
      ),
      validator: validator,
    );
  }
}
