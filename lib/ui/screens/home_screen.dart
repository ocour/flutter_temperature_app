import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/auth/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          children: [
            const Text("Welcome"),
            ElevatedButton(
                onPressed: () async {
                  Navigator.pushNamed(context, "screen-2");
                },
                child: const Text("navigate"),
            )
          ],
        ),
      ),
    );
  }
}

class Screen2 extends StatelessWidget {
  const Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Screen2"),
      ),
      body: Center(
        child: Column(
          children: [
            const Text("Welcome"),
            ElevatedButton(
              onPressed: () async {
                await context.read<AuthService>().signOut();
              },
              child: const Text("SignOut"),
            )
          ],
        ),
      ),
    );
  }
}