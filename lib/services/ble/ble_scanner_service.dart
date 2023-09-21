import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:temperature_app/services/reactive_state.dart';

import 'ble_scanner_state.dart';
import 'temperature_sensor/uuids.dart';
import 'utils/typedefs.dart';

class BleScannerService implements ReactiveState<BleScannerState> {
  BleScannerService({
    required FlutterReactiveBle ble,
    required LogMessage logMessage,
  })  : _ble = ble,
        _logMessage = logMessage {
    _log("BleScannerService created.");
  }

  final FlutterReactiveBle _ble;
  final LogMessage _logMessage;

  static const _tag = "BleScannerService";

  final StreamController<BleScannerState> _scannerStreamController =
      StreamController();
  StreamSubscription? _scanSubscription;
  final _devices = <DiscoveredDevice>[];

  @override
  Stream<BleScannerState> get state => _scannerStreamController.stream;

  void _log(String message, {Object? error}) {
    _logMessage(name: _tag, message: message, error: error);
  }

  void startScan() {
    _log("Starting scanning.");
    _devices.clear();
    _scanSubscription?.cancel();
    _scanSubscription = _ble.scanForDevices(withServices: [temperatureSensorService]).listen(
      (device) {
        // Check if device has already been discovered
        // if so update its value in list, otherwise add device to list
        final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
        if (knownDeviceIndex >= 0) {
          _devices[knownDeviceIndex] = device;
        } else {
          _log("Found new device with id: ${device.id}");
          _devices.add(device);
        }
        _pushState();
      },
      onError: (Object e) => _log(
        "Device scan failed with error: $e",
        error: e,
      ),
    );
    _pushState();
  }

  Future<void> stopScan() async {
    _log("Stopping scanning");
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    _pushState();
  }

  void _pushState() {
    _scannerStreamController.add(
      BleScannerState(
          discoveredDevices: _devices,
          scanIsInProgress: _scanSubscription != null),
    );
  }

  Future<void> dispose() async {
    // Stop scan only if in progress
    if(_scanSubscription != null) {
      await stopScan();
    }
    await _scannerStreamController.close();
    _log("Scanner stream closed.");
  }
}
