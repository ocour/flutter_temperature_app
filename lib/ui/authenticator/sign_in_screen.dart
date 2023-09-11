import 'package:amplify_flutter/amplify_flutter.dart' show safePrint;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/ui/authenticator/confirm_new_password_screen.dart';
import 'package:temperature_app/ui/authenticator/sign_out_screen.dart';
import 'package:temperature_app/ui/utils/password_text_form_field.dart';
import 'package:temperature_app/ui/utils/username_text_form_field.dart';

import '../../services/auth/auth_exceptions.dart';
import '../../services/auth/auth_next_step.dart';
import '../../services/auth/auth_service.dart';
import '../utils/error_card.dart';
import '../utils/divider.dart' as util;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const String routeName = "/auth/sign-in";

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  Future<void> _signIn() async {
    try {
      _startLoading();
      final username = _usernameController.text;
      final password = _passwordController.text;
      final nextStep = await context
          .read<AuthService>()
          .signIn(username: username, password: password);
      _handleNextStep(nextStep.step);
    } on AuthUserNotFoundException {
      _showErrorWithMessage("Incorrect username or password");
    } on AuthWrongPasswordException {
      _showErrorWithMessage("Incorrect username or password");
    } on AuthUnknownException catch (e) {
      _showErrorWithMessage("Unknown error: ${e.message}");
    } finally {
      _stopLoading();
    }
  }

  void _handleNextStep(AuthStep nextStep) {
    switch (nextStep) {
      case AuthStep.confirmSignInWithNewPassword:
        Navigator.pushNamedAndRemoveUntil(
          context,
          ConfirmNewPasswordScreen.routeName,
          (route) => false,
        );
        break;
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

  final Widget divider = const util.Divider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Sign In"),
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      ErrorCard(message: _errorMessage!),
                    divider,
                    UsernameTextFormField(
                      enabled: !_isLoading,
                      controller: _usernameController,
                      labelText: "Username",
                    ),
                    divider,
                    PasswordTextFormField(
                      enabled: !_isLoading,
                      controller: _passwordController,
                      labelText: "Password",
                      validator: (String? value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 8) {
                          return "Password has to be longer than 8 characters";
                        } else if (value != null && value.isEmpty) {
                          return "Password cannot be empty";
                        } else {
                          return null;
                        }
                      },
                    ),
                    divider,
                    FilledButton(
                      onPressed: !_isLoading
                          ? () async {
                              _resetErrorMessage();
                              if (_formKey.currentState!.validate()) {
                                await _signIn();
                              }
                            }
                          : null,
                      child: const Text("Sign In"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
