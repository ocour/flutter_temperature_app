import 'package:flutter/material.dart';
import 'package:temperature_app/ui/utils/temperature_app_app_bar.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TemperatureAppAppBar(
        title: "Loading",
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
