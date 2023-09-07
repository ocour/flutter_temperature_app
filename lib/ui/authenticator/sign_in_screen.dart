import 'package:amplify_flutter/amplify_flutter.dart' show safePrint;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/ui/authenticator/confirm_new_password_screen.dart';

import '../../services/auth/auth_exceptions.dart';
import '../../services/auth/auth_provider.dart';
import '../../services/auth/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const String routeName = "auth/sign-in";

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
  void initState() {
    super.initState();
  }

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

  void startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void stopLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  // TODO: ADD LOADING VARIABLE
  Future<void> _signIn() async {
    try {
      startLoading();
      final username = _usernameController.text;
      final password = _passwordController.text;
      final nextStep = await context
          .read<AuthService>()
          .signIn(username: username, password: password);
      await _handleNextStep(nextStep);
    } on AuthUserNotFoundException {
      _showErrorWithMessage("Incorrect username or password");
    } on AuthWrongPasswordException {
      _showErrorWithMessage("Incorrect username or password");
    } on AuthUnknownException catch(e) {
      _showErrorWithMessage("Unknown error: ${e.message}");
    } finally {
      stopLoading();
    }
  }

  Future<void> _handleNextStep(AuthNextStep nextStep) async {
    switch (nextStep) {
      case AuthNextStep.confirmSignInWithNewPassword:
        Navigator.pushNamedAndRemoveUntil(
          context,
          ConfirmNewPasswordScreen.routeName,
          (route) => false,
        );
        break;
      case AuthNextStep.done:
        // No need to navigate,
        // it will be done automatically once isSignedIn changes
        safePrint("Successfully signed in!");
        break;
      default:
        safePrint("Next step is not implemented!");
    }
  }

  final divider = const SizedBox(height: 16.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Sign In"),
      ),
      body: Column(
        children: [
         if(_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if(_errorMessage != null) ErrorCard(message: _errorMessage!),
                    divider,
                    TextFormField(
                      controller: _usernameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        icon: const Icon(Icons.person_rounded),
                        labelText: "Username",
                        errorText: _errorMessage != null ? "" : null,
                      ),
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return "Username cannot be empty";
                        } else {
                          return null;
                        }
                      },
                    ),
                    divider,
                    TextFormField(
                      controller: _passwordController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        icon: const Icon(Icons.password_rounded),
                        labelText: "Password",
                        errorText: _errorMessage != null ? "" : null,
                      ),
                      validator: (String? value) {
                        if (value != null && value.isNotEmpty && value.length < 8) {
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
                      onPressed: () async {
                        _resetErrorMessage();
                        if (_formKey.currentState!.validate()) {
                          await _signIn();
                          // TODO: DISABLE BUTTON
                        }
                      },
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

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                child: Icon(Icons.error_outline_rounded),
              ),
              Flexible(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
