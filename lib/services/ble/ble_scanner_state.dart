import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

@immutable
class BleScannerState {
  final List<DiscoveredDevice> discoveredDevices;
  final bool scanIsInProgress;

  const BleScannerState({
    required this.discoveredDevices,
    required this.scanIsInProgress,
  });
}