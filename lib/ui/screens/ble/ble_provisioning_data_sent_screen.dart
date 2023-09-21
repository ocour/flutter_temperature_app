import 'package:flutter/material.dart';
import 'package:temperature_app/ui/utils/temperature_app_app_bar.dart';

class BleProvisioningDataSentScreen extends StatelessWidget {
  const BleProvisioningDataSentScreen({super.key});

  static const String routeName = "/device-provision/data-sent";

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TemperatureAppAppBar(
        title: "Data sent",
      ),
      body: Text("Data was sent."),
    );
  }
}
