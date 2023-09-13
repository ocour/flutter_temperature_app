import 'package:flutter/material.dart';
import 'package:temperature_app/ui/utils/temperature_app_app_bar.dart';

class BleProvisionNewDeviceBody extends StatelessWidget {
  const BleProvisionNewDeviceBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TemperatureAppAppBar(title: "Provision device"),
      body: Text("Success"),
    );
  }
}
