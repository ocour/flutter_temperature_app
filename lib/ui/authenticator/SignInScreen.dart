import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/ui/authenticator/ConfirmNewPasswordScreen.dart';

import '../../services/AuthService.dart';

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

  Future<void> _signIn() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final nextStep = await context
        .read<AuthService>()
        .signIn(username: username, password: password);
    await _handleNextStep(nextStep);
  }

  Future<void> _handleNextStep(AuthSignInStep nextStep) async {
    switch (nextStep) {
      case AuthSignInStep.confirmSignInWithNewPassword:
        Navigator.pushNamedAndRemoveUntil(
          context,
          ConfirmNewPasswordScreen.routeName,
          (route) => false,
        );
        break;
      case AuthSignInStep.done:
        safePrint("Successfully signed in!");
        break;
      default:
        safePrint("Step $nextStep is not implemented!");
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _usernameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.person_rounded),
                    labelText: "Username",
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
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.password_rounded),
                      labelText: "Password"),
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
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _signIn();
                      print("valid sign-in parameters");
                    }
                  },
                  child: const Text("Sign In"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
