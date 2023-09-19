import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

abstract class BleDeviceInteractor {

  /// fetch all services of connected device
  Future<List<Service>> discoverServices({required String deviceId});

  /// Will return true if all required services are supported, false otherwise
  bool supportsRequiredServices({required List<Service> services});

  /// Writes [value] to [characteristic], TODO: describe possible exceptions
  Future<void> writeCharacteristicWithResponse({
    required String deviceId,
    required String value,
    required QualifiedCharacteristic characteristic,
  });
}