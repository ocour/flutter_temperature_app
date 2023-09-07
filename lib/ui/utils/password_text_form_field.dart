import 'package:flutter/material.dart';

class PasswordTextFormField extends StatelessWidget {
  const PasswordTextFormField({
    super.key,
    this.controller,
    this.enabled,
    this.errorText,
    this.labelText,
    this.validator,
  });

  final TextEditingController? controller;
  final bool? enabled;
  final String? errorText;
  final String? labelText;
  final String? Function(String? value)? validator;

  String? defaultValidator(String? value) {
    if (value != null && value.isNotEmpty && value.length < 8) {
      return "Password has to be longer than 8 characters";
    } else if (value != null && value.isEmpty) {
      return "Password cannot be empty";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: true,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        icon: const Icon(Icons.password_rounded),
        labelText: labelText,
        errorText: errorText,
      ),
      validator: validator ?? defaultValidator,
    );
  }
}
