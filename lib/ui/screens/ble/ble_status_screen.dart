import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/logger_service.dart';
import 'package:temperature_app/ui/screens/ble/ble_app_bar.dart';
import 'package:temperature_app/ui/utils/divider.dart';

import '../../utils/temperature_app_app_bar.dart';

class BleStatusScreen extends StatelessWidget {
  const BleStatusScreen({super.key, required this.status});

  static const _loggerTag = "BleStatusScreen";

  final BleStatus status;

  /// Requests the permissions that Bluetooth requires
  Future<void> requestPermissions(BuildContext context) async {
    final log = context.read<LoggerService>().log;

    Map<Permission, PermissionStatus> statuses = await [
      // Android SDK Version 30 and lower
      Permission.locationWhenInUse,
      // Android SDK Version 31 and up
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();

    statuses.forEach((key, value) {
      log(name: _loggerTag, message: "$key status: $value");
    });
  }

  Widget _determineWidget(BuildContext context) {
    switch (status) {
      case BleStatus.unsupported:
        return const BleInformationWidget(
          icon: Icons.error_outline_rounded,
          informationText: "This device does not support Bluetooth LE.",
        );
      case BleStatus.unauthorized:
        requestPermissions(context);
        return BleUnauthorizedWidget(
          requestPermissions: requestPermissions,
        );
      case BleStatus.poweredOff:
        return const BleInformationWidget(
          icon: Icons.error_outline_rounded,
          informationText: "Bluetooth is powered off, please turn it on.",
        );
      case BleStatus.locationServicesDisabled:
        return const BleInformationWidget(
          icon: Icons.error_outline_rounded,
          informationText: "Enable location (GPS) to use this service.",
        );
      case BleStatus.ready:
        return const BleInformationWidget(
          icon: Icons.info_outline_rounded,
          informationText: "Bluetooth is up and running.",
        );
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Fetching Bluetooth status...",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const MyDivider(height: 32),
            const CircularProgressIndicator(),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BleAppBar(
        title: "Ble Status",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _determineWidget(context),
        ),
      ),
    );
  }
}

class BleInformationWidget extends StatelessWidget {
  const BleInformationWidget({
    super.key,
    required this.icon,
    required this.informationText,
  });

  final IconData icon;
  final String informationText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 32.0,
        ),
        const MyDivider(),
        Text(
          informationText,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class BleUnauthorizedWidget extends StatelessWidget {
  const BleUnauthorizedWidget({super.key, required this.requestPermissions});

  final Future<void> Function(BuildContext context) requestPermissions;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 32.0,
        ),
        const MyDivider(),
        Text(
          "Authorize the app to use Bluetooth and Location services.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const MyDivider(),
        ElevatedButton(
          onPressed: () => requestPermissions(context),
          child: const Text("Request permissions"),
        ),
      ],
    );
  }
}
