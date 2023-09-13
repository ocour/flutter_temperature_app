import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:temperature_app/services/ble/ble_device_connection_state.dart';

@immutable
class BleConnectionState {
  final String deviceId;
  final BleDeviceConnectionState connectionState;
  final GenericFailure<ConnectionError>? failure;

  const BleConnectionState({
    required this.deviceId,
    required this.connectionState,
    required this.failure,
  });
}