import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:temperature_app/services/ble/ble_connection_state.dart';
import 'package:temperature_app/services/ble/ble_device_connection_state.dart';
import 'package:temperature_app/services/reactive_state.dart';

class BleConnectorService implements ReactiveState<BleConnectionState> {
  BleConnectorService({
    required FlutterReactiveBle ble,
    required void Function({
      required String name,
      required String message,
      Object? error,
    }) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage {
    _log("BleConnectorService created.");
  }

  static const _tag = "BleConnectorService";
  static const preScanDuration = Duration(seconds: 10);
  static const connectionTimeout = preScanDuration;

  final FlutterReactiveBle _ble;
  final void Function({
    required String name,
    required String message,
    Object? error,
  }) _logMessage;

  String? connectedDeviceId;
  final StreamController<BleConnectionState> _deviceConnectionController =
      StreamController();
  StreamSubscription<ConnectionStateUpdate>? _connection;

  @override
  Stream<BleConnectionState> get state => _deviceConnectionController.stream;

  void _emit({
    required BleDeviceConnectionState connectionState,
    String? deviceId,
    GenericFailure<ConnectionError>? failure,
  }) {
    _deviceConnectionController.add(
      BleConnectionState(
        deviceId: deviceId ?? "Unknown device",
        connectionState: connectionState,
        failure: failure,
      ),
    );
  }

  Future<void> connect(String deviceId) async {
    _log("Started connecting to device: $deviceId");
    // Set initial connection state to connecting
    _emit(
      connectionState: BleDeviceConnectionState.connecting,
      deviceId: deviceId,
      failure: null,
    );

    // Cancel existing connection if it exists
    await _connection?.cancel();
    // Start connecting
    _connection = _ble
        .connectToAdvertisingDevice(
            id: deviceId,
            withServices: [],
            prescanDuration: preScanDuration,
            connectionTimeout: connectionTimeout)
        .listen(
      (update) {
        _log(
          "Connection state update for device $deviceId: ${update.connectionState}",
        );
        switch (update.connectionState) {
          case DeviceConnectionState.connecting:
            _emit(
              connectionState: BleDeviceConnectionState.connecting,
              deviceId: update.deviceId,
              failure: update.failure,
            );
            break;
          case DeviceConnectionState.connected:
            connectedDeviceId = update.deviceId;
            _emit(
              connectionState: BleDeviceConnectionState.connected,
              deviceId: update.deviceId,
              failure: update.failure,
            );
            break;
          case DeviceConnectionState.disconnecting:
            _emit(
              connectionState: BleDeviceConnectionState.disconnecting,
              deviceId: update.deviceId,
              failure: update.failure,
            );
            break;
          case DeviceConnectionState.disconnected:
            _emit(
              connectionState: BleDeviceConnectionState.disconnected,
              deviceId: update.deviceId,
              failure: update.failure,
            );
            break;
        }
      },
      onError: (Object e) => _log(
        "Connecting to device $deviceId returned error $e",
        error: e,
      ),
    );
  }

  Future<void> disconnect() async {
    _log("Disconnecting from device $connectedDeviceId");
    // Disconnect
    await _connection?.cancel();
    // Set state to disconnected
    _emit(
      deviceId: connectedDeviceId,
      connectionState: BleDeviceConnectionState.disconnected,
      failure: null,
    );
    connectedDeviceId = null;
  }

  Future<void> dispose() async {
    // Disconnect only if connected
    if (connectedDeviceId != null) {
      await disconnect();
    }
    await _deviceConnectionController.close();
    _log("Connector stream closed.");
  }

  /// Reset state back to [BleDeviceConnectionState.none]
  void reset() {
    _log("Resetting state back to none.");
    _emit(
      connectionState: BleDeviceConnectionState.none,
    );
  }

  void _log(String message, {Object? error}) {
    _logMessage(name: _tag, message: message, error: error);
  }
}
