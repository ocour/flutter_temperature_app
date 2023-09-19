import 'package:flutter/material.dart';
import 'package:temperature_app/ui/utils/non_secret_text_form_field.dart';

class WifiSsidTextFormField extends StatelessWidget {
  const WifiSsidTextFormField({
    super.key,
    this.controller,
    this.labelText,
    this.enabled,
    this.validator, this.errorText,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? errorText;
  final bool? enabled;
  final String? Function(String? value)? validator;

  String? defaultValidator(String? value) {
    if (value != null && value.isEmpty) {
      return "Wi-Fi SSID cannot be empty";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NonSecretTextFormField(
      enabled: enabled,
      controller: controller,
      labelText: labelText,
      errorText: errorText,
      icon: Icons.wifi_rounded,
      validator: validator ?? defaultValidator,
    );
  }
}
