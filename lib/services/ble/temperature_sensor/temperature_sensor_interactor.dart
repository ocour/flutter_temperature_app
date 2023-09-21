import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:temperature_app/services/ble/ble_device_interactor.dart';
import 'package:temperature_app/services/ble/exceptions/exceptions.dart';
import 'package:temperature_app/services/ble/temperature_sensor/uuids.dart';
import 'package:temperature_app/services/ble/utils/typedefs.dart';
import 'dart:convert';

class TemperatureSensorInteractor implements BleDeviceInteractor {
  TemperatureSensorInteractor({
    required FlutterReactiveBle ble,
    required LogMessage logMessage,
  })  : _ble = ble,
        _logMessage = logMessage;

  static const _tag = "TemperatureSensorInteractor";

  final FlutterReactiveBle _ble;
  final LogMessage _logMessage;

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    _logMessage(
        name: _tag, message: message, error: error, stackTrace: stackTrace);
  }

  // TODO: REMOVE
  void _printServices(List<Service> services) {
    for (var service in services) {
      if (service.id == temperatureSensorService) {
        print("");
        print(
            "service: $service, id: ${service.id}, deviceId: ${service.deviceId}");
        for (var characteristic in service.characteristics) {
          print("characteristic: $characteristic");
          print("id: ${characteristic.id}");
          print("characteristic service: ${characteristic.service}");
          print("isReadable: ${characteristic.isReadable}");
          print("isIndicatable: ${characteristic.isIndicatable}");
          print("isNotifiable: ${characteristic.isNotifiable}");
          print(
              "isWritableWithResponse: ${characteristic.isWritableWithResponse}");
          print(
              "isWritableWithoutResponse: ${characteristic.isWritableWithoutResponse}");
        }
        print("");
      }
    }
  }

  /// Throws [DiscoverServicesExceptions] exception if an exception occurred
  /// while discovering services
  @override
  Future<List<Service>> discoverServices({required String deviceId}) async {
    try {
      _log("Start discovering service for device with id: $deviceId");
      await _ble.discoverAllServices(deviceId);
      final result = await _ble.getDiscoveredServices(deviceId);
      _log("Services retrieved successfully");
      return result;
    } on Exception catch (e) {
      _log("Error occurred while discovering services: $e", error: e);
      throw DiscoverServicesExceptions();
    }
  }

  @override
  bool supportsRequiredServices({required List<Service> services}) {
    return services.any((service) => service.id == temperatureSensorService);
  }

  @override
  Future<void> writeCharacteristicWithResponse({
    required String deviceId,
    required String value,
    required QualifiedCharacteristic characteristic,
  }) async {
    try {
      // Check that value is ascii
      final validValue = ascii.encode(value).toList();

      await _ble.writeCharacteristicWithResponse(characteristic,
          value: validValue);
      _log(
          "Successfully wrote value to characteristic with id: ${characteristic.characteristicId}");
    } on GenericFailure<WriteCharacteristicFailure> catch (e) {
      _log("Writing to characteristic failed with message: ${e.message}",
          error: e);
      throw BleWriteCharacteristicException(e.message);
    } on ArgumentError {
      _log("Writing to characteristic failed because value is not valid ascii");
      throw BleWriteCharacteristicArgumentException();
    } on Exception {
      _log("Writing to characteristic failed because of an unknown error");
      throw BleWriteCharacteristicUnknownException();
    }
  }

  Future<void> writeWifiSsid({
    required String deviceId,
    required String value,
  }) async {
    final characteristic = QualifiedCharacteristic(
        characteristicId: temperatureSensorWifiSsidCharacteristic,
        serviceId: temperatureSensorService,
        deviceId: deviceId
    );

    await writeCharacteristicWithResponse(
        deviceId: deviceId,
        value: value,
        characteristic: characteristic,
    );
  }

  Future<void> writeWifiPwd({
    required String deviceId,
    required String value,
  }) async {
    final characteristic = QualifiedCharacteristic(
        characteristicId: temperatureSensorWifiPwdCharacteristic,
        serviceId: temperatureSensorService,
        deviceId: deviceId
    );

    await writeCharacteristicWithResponse(
      deviceId: deviceId,
      value: value,
      characteristic: characteristic,
    );
  }

  Future<void> writeThingName({
    required String deviceId,
    required String value,
  }) async {
    final characteristic = QualifiedCharacteristic(
        characteristicId: temperatureSensorAwsThingNameCharacteristic,
        serviceId: temperatureSensorService,
        deviceId: deviceId
    );

    await writeCharacteristicWithResponse(
      deviceId: deviceId,
      value: value,
      characteristic: characteristic,
    );
  }

  Future<void> writeProvCpl({
    required String deviceId,
    required int value,
  }) async {
    final characteristic = QualifiedCharacteristic(
        characteristicId: temperatureSensorProvCplCharacteristic,
        serviceId: temperatureSensorService,
        deviceId: deviceId
    );

    await writeCharacteristicWithResponse(
      deviceId: deviceId,
      value: value.toString(),
      characteristic: characteristic,
    );
  }

  /// Will inform the temperature device that all data has been sent
  Future<void> informCompleteProvisioning({
    required String deviceId,
  }) async {
    await writeProvCpl(
      deviceId: deviceId,
      value: 1,
    );
  }
}
