import 'package:flutter/material.dart';

import 'authenticator_app_bar.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AuthenticatorAppBar(
        title: "Loading",
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
