import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/ble/ble_device_connection_state.dart';
import 'package:temperature_app/ui/screens/ble/ble_device_connection_state_body.dart';

import '../../../services/ble/ble_connection_state.dart';
import '../../../services/ble/ble_connector_service.dart';
import 'ble_provision_new_device_body.dart';

class BleConnectToDeviceScreen extends StatefulWidget {
  const BleConnectToDeviceScreen({super.key, required this.device});

  static const String routeName = "/device-provision/provision-new-device";
  final DiscoveredDevice device;

  @override
  State<BleConnectToDeviceScreen> createState() => _BleConnectToDeviceScreenState();
}

class _BleConnectToDeviceScreenState extends State<BleConnectToDeviceScreen> {
  late BleConnectorService _connector;

  @override
  void initState() {
    super.initState();
    context.read<BleConnectorService>().connect(widget.device.id);
  }

  @override
  void didChangeDependencies() {
    /// Get [BleConnectorService] here as getting [context] inside dispose() is
    /// unsafe in this case
    _connector = context.read<BleConnectorService>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _connector.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BleConnectionState?>(
      builder: (_, state, __) {
        if(state?.connectionState != BleDeviceConnectionState.connectedAndDoesSupportServices) {
          return BleDeviceConnectionStateBody(
              state: state ?? const BleConnectionState(
                deviceId: "Unknown device",
                connectionState: BleDeviceConnectionState.none,
                failure: null,
              )
          );
        } else {
          return BleProvisionNewDeviceBody(deviceId: widget.device.id);
        }
      },
    );
  }
}
