import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/auth/auth_exceptions.dart';
import 'package:temperature_app/services/auth/auth_service.dart';
import 'package:temperature_app/ui/authenticator/authenticator_app_bar.dart';

import '../../services/auth/auth_next_step.dart';
import '../utils/error_card.dart';
import '../utils/password_text_form_field.dart';
import '../utils/divider.dart' as util;

class ConfirmNewPasswordScreen extends StatefulWidget {
  const ConfirmNewPasswordScreen({super.key});

  static const String routeName = "/auth/confirm-new-password";

  @override
  State<ConfirmNewPasswordScreen> createState() =>
      _ConfirmNewPasswordScreenState();
}

class _ConfirmNewPasswordScreenState extends State<ConfirmNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  String? _errorMessage;
  String? _textFieldErrorText;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _stopLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorWithMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _resetErrorMessage() {
    setState(() {
      _errorMessage = null;
    });
  }

  void _updateTextFieldErrorText(String? errorText) {
    setState(() {
      _textFieldErrorText = errorText;
    });
  }

  Future<void> _confirmNewPassword() async {
    try {
      _startLoading();
      final newPassword = _newPasswordController.text;
      final nextStep =
          await context.read<AuthService>().confirmNewPassword(newPassword);
      _handleNextStep(nextStep.step);
    } on AuthUnknownException catch (e) {
      _showErrorWithMessage("Unknown error: ${e.message}");
    } finally {
      _stopLoading();
    }
  }

  void _handleNextStep(AuthStep nextStep) {
    switch (nextStep) {
      case AuthStep.done:
        // No need to navigate, as it will be done automatically
        // once isSignedIn changes
        safePrint("Successfully signed in!");
        break;
      default:
        safePrint("AuthStep: '$nextStep' is not implemented!");
        _showErrorWithMessage("AuthStep: '$nextStep' is not implemented!");
    }
  }

  final divider = const util.MyDivider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthenticatorAppBar(title: "New Password"),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_errorMessage != null) ErrorCard(message: _errorMessage!),
                  divider,
                  PasswordTextFormField(
                    enabled: !_isLoading,
                    controller: _newPasswordController,
                    labelText: "New Password",
                  ),
                  divider,
                  PasswordTextFormField(
                    enabled: !_isLoading,
                    controller: _confirmNewPasswordController,
                    labelText: "Confirm New Password",
                    errorText: _textFieldErrorText,
                  ),
                  divider,
                  ElevatedButton(
                      // disable button if loading is in progress
                      onPressed: !_isLoading
                          ? () async {
                              _resetErrorMessage();
                              if (_formKey.currentState!.validate()) {
                                final newPasswordText =
                                    _newPasswordController.text;
                                final confirmNewPasswordText =
                                    _confirmNewPasswordController.text;

                                if (newPasswordText != confirmNewPasswordText) {
                                  _updateTextFieldErrorText(
                                      "Passwords must match");
                                } else {
                                  _updateTextFieldErrorText(null);
                                  await _confirmNewPassword();
                                }
                              }
                            }
                          : null,
                      child: const Text("Confirm")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
