import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/AuthService.dart';

class SignOutScreen extends StatelessWidget {
  const SignOutScreen({super.key});

  static const String routeName = "auth/sign-out";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Sign Out"),
      ),
      body: Center(
        child: Column(
          children: [
            const Text("Sign Out"),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await context.read<AuthService>().signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    SignOutScreen.routeName,
                    (route) => false,
                  );
                }
              },
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
