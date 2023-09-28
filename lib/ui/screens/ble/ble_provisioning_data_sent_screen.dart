import 'package:flutter/material.dart';
import 'package:temperature_app/ui/screens/ble/ble_app_bar.dart';

class BleProvisioningDataSentScreen extends StatelessWidget {
  const BleProvisioningDataSentScreen({super.key, required this.onDone});

  static const String routeName = "/device-provision/data-sent";

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BleAppBar(
        title: "Data sent",
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                "Data was sent but there was no guarantee that the data you sent was correct."),
            const Text(
                "To see if the sensor was successfully registered, wait some time to see if it starts sending temperature data."),
            const Text("If not re-flash the sensor."),
            const SizedBox(height: 16.0),
            ElevatedButton(
                onPressed: onDone,
                child: const Text("Understood"),
            ),
          ],
        ),
      ),
    );
  }
}
