import 'package:flutter/material.dart';

class SecretTextFormField extends StatelessWidget {
  const SecretTextFormField({super.key, this.controller, this.labelText, this.enabled, this.errorText, this.validator, this.icon});

  final TextEditingController? controller;
  final String? labelText;
  final bool? enabled;
  final String? errorText;
  final String? Function(String? value)? validator;
  final IconData? icon;

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
        icon: Icon(icon),
        labelText: labelText,
        errorText: errorText,
      ),
      validator: validator,
    );
  }
}