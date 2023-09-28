import 'package:flutter/material.dart';

class TemperatureDeviceCard extends StatelessWidget {
  const TemperatureDeviceCard({super.key, required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;
  static const double padding = 16.0;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: Theme.of(context).colorScheme.secondaryContainer,
      leading: Icon(
        Icons.thermostat_rounded,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      title: Text(
        name,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
