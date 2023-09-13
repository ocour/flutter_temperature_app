import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth/auth_service.dart';
import '../utils/temperature_app_app_bar.dart';
import 'ble/device_provisioning_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TemperatureAppAppBar(title: "Temperature App"),
      body: Center(
        child: Column(
          children: [
            const Text("Welcome"),
            ElevatedButton(
                onPressed: () async {
                  Navigator.pushNamed(context, DeviceProvisioningScreen.routeName);
                },
                child: const Text("Provision device"),
            ),
            const Text("Sign out"),
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