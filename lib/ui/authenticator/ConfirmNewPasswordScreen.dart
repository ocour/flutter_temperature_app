import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/AuthService.dart';

class ConfirmNewPasswordScreen extends StatefulWidget {
  const ConfirmNewPasswordScreen({super.key});

  static const String routeName = "auth/confirm-new-password";

  @override
  State<ConfirmNewPasswordScreen> createState() => _ConfirmNewPasswordScreenState();
}

class _ConfirmNewPasswordScreenState extends State<ConfirmNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _updateErrorText(String errorText) {
    setState(() {
      _errorText = errorText;
    });
  }

  Future<void> _confirmNewPassword() async {
    final newPassword = _newPasswordController.text;
    context.read<AuthService>().confirmNewPassword(newPassword);
  }

  final divider = const SizedBox(height: 16.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("New Password"),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _newPasswordController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.password_rounded),
                    labelText: "New Password"),
                validator: (String? value) {
                  if(value != null && value.isNotEmpty && value.length < 8) {
                    return "Password has to be longer than 8 characters";
                  } else if(value != null && value.isEmpty) {
                    return "Password cannot be empty";
                  } else {
                    return null;
                  }
                },
              ),
              divider,
              TextFormField(
                controller: _confirmNewPasswordController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    icon: const Icon(Icons.password_rounded),
                    labelText: "Confirm New Password",
                    errorText: _errorText,
                ),
                validator: (String? value) {
                  if(value != null && value.isNotEmpty && value.length < 8) {
                    return "Password has to be longer than 8 characters";
                  } else if(value != null && value.isEmpty) {
                    return "Password cannot be empty";
                  } else {
                    return null;
                  }
                },
              ),
              divider,
              ElevatedButton(
                  onPressed: () async {
                    if(_formKey.currentState!.validate()) {
                      final newPasswordText = _newPasswordController.text;
                      final confirmNewPasswordText = _confirmNewPasswordController.text;

                      if(newPasswordText != confirmNewPasswordText) {
                        _updateErrorText("Passwords must match");
                      } else {
                        await _confirmNewPassword();
                      }
                    }
                  },
                  child: const Text("Confirm")
              ),
            ],
          ),
        ),
      ),
    );
  }
}
