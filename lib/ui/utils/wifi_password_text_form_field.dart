import 'package:flutter/material.dart';

import 'secret_text_form_field.dart';

class WifiPasswordTextFormField extends StatelessWidget {
  const WifiPasswordTextFormField({super.key, this.controller, this.enabled, this.errorText, this.labelText, this.validator});

  final TextEditingController? controller;
  final bool? enabled;
  final String? errorText;
  final String? labelText;
  final String? Function(String? value)? validator;

  String? defaultValidator(String? value) {
    if (value != null && value.isEmpty) {
      return "Password cannot be empty";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecretTextFormField(
      enabled: enabled,
      controller: controller,
      labelText: labelText,
      errorText: errorText,
      icon: Icons.password_rounded,
      validator: validator ?? defaultValidator,
    );
  }
}
