import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/ble/ble_connector_service.dart';
import 'package:temperature_app/services/ble/ble_scanner_service.dart';
import 'package:temperature_app/services/ble/ble_scanner_state.dart';
import 'package:temperature_app/services/logger_service.dart';
import 'package:temperature_app/ui/utils/temperature_app_app_bar.dart';

import 'ble_connect_to_device_screen.dart';

class BleScanScreen extends StatefulWidget {
  const BleScanScreen({super.key});

  static const String routeName = "/device-provision/scan";

  @override
  State<BleScanScreen> createState() => _BleScanScreenState();
}

class _BleScanScreenState extends State<BleScanScreen> {
  late final BleScannerService _scanner;

  @override
  void initState() {
    super.initState();
    final ble = context.read<FlutterReactiveBle>();
    final logger = context.read<LoggerService>();
    _scanner = BleScannerService(ble: ble, logMessage: logger.log);
  }

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider.value(value: _scanner),
          StreamProvider<BleScannerState?>(
              create: (context) => _scanner.state,
              initialData: const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              )
          ),
        ],
      child: Scaffold(
        appBar: const TemperatureAppAppBar(
          title: "Scan for sensor devices",
        ),
        body: Consumer2<BleScannerService, BleScannerState?>(
          builder: (_, scanner, state, __) => BleScanBody(
              startScan: scanner.startScan,
              stopScan: scanner.stopScan,
              scanIsInProgress: state?.scanIsInProgress ?? false,
              devices: state?.discoveredDevices ?? [],
          ),
        ),
      ),
    );
  }
}

class BleScanBody extends StatelessWidget {
  const BleScanBody({
    super.key,
    required this.startScan,
    required this.stopScan,
    required this.scanIsInProgress,
    required this.devices,
  });

  final VoidCallback startScan;
  final VoidCallback stopScan;
  final bool scanIsInProgress;
  final List<DiscoveredDevice> devices;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(scanIsInProgress) const LinearProgressIndicator(),
        SwitchListTile(
          title: Text(
            "Start scanning",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          value: scanIsInProgress,
          onChanged: (newState) {
            if (newState) {
              startScan();
            } else {
              stopScan();
            }
          },
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Divider(
            thickness: 2,
            height: 1,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return BleDeviceCard(
                  device: device,
                  stopScan: stopScan,
                  scanIsInProgress: scanIsInProgress,
                );
              },
            ),
          ),
        )
      ],
    );
  }
}

class BleDeviceCard extends StatelessWidget {
  const BleDeviceCard({
    super.key,
    required this.device,
    required this.stopScan,
    required this.scanIsInProgress,
  });

  final DiscoveredDevice device;
  final VoidCallback stopScan;
  final bool scanIsInProgress;

  Future<void> onTap(BuildContext context) async {
    if (scanIsInProgress) {
      stopScan();
    }
    // Navigate to BleDeviceConnectionStateScreen passing it the device that
    // we want to connect to
    await Navigator.of(context).pushNamed(
        BleConnectToDeviceScreen.routeName,
      arguments: device
    );

    // Reset [BleConnectionState] back to [BleDeviceConnectionState.none] after
    // navigating back
    if(context.mounted) {
      context.read<BleConnectorService>().reset();
    }
  }

  bool isConnectable(Connectable state) {
    return state == Connectable.available;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        color: isConnectable(device.connectable)
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceVariant,
        child: ListTile(
          onTap: !isConnectable(device.connectable)
              ? null
              : () {
            onTap(context);
          },
          leading: Icon(
            Icons.bluetooth_rounded,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          title: Text(
            device.name.isEmpty ? "Unknown" : device.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              device.id,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          trailing: IconButton(
            onPressed: !isConnectable(device.connectable)
                ? null
                : () {
              onTap(context);
            },
            icon: Icon(
              isConnectable(device.connectable)
                  ? Icons.arrow_forward_rounded
                  : null,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}