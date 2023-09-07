import 'package:flutter/material.dart';

class UsernameTextFormField extends StatelessWidget {
  const UsernameTextFormField({
    super.key,
    this.controller,
    this.labelText,
    this.enabled,
    this.errorText,
    this.validator,
  });

  final TextEditingController? controller;
  final String? labelText;
  final bool? enabled;
  final String? errorText;
  final String? Function(String? value)? validator;

  String? defaultValidator(String? value) {
    if (value != null && value.isEmpty) {
      return "Username cannot be empty";
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
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        icon: const Icon(Icons.person_rounded),
        labelText: labelText,
        errorText: errorText,
      ),
      validator: validator ?? defaultValidator,
    );
  }
}
