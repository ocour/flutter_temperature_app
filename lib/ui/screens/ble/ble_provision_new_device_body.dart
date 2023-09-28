import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/api/exceptions.dart';
import 'package:temperature_app/services/api/temperature_api_service.dart';
import 'package:temperature_app/services/api/thing_name.dart';
import 'package:temperature_app/services/ble/exceptions/exceptions.dart';
import 'package:temperature_app/services/ble/temperature_sensor/temperature_sensor_interactor.dart';
import 'package:temperature_app/ui/screens/ble/ble_app_bar.dart';
import 'package:temperature_app/ui/screens/ble/ble_provisioning_data_sent_screen.dart';
import 'package:temperature_app/ui/utils/divider.dart';
import 'package:temperature_app/ui/utils/error_card.dart';
import 'package:temperature_app/ui/utils/non_secret_text_form_field.dart';
import 'package:temperature_app/ui/utils/temperature_app_app_bar.dart';
import 'package:temperature_app/ui/utils/wifi_password_text_form_field.dart';

import '../../utils/wifi_ssid_text_form_field.dart';

class BleProvisionNewDeviceBody extends StatefulWidget {
  const BleProvisionNewDeviceBody({super.key, required this.deviceId});

  final String deviceId;

  @override
  State<BleProvisionNewDeviceBody> createState() =>
      _BleProvisionNewDeviceBodyState();
}

class _BleProvisionNewDeviceBodyState extends State<BleProvisionNewDeviceBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _wifiSsidController;
  late final TextEditingController _wifiPwdController;
  late final TextEditingController _thingNameController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _wifiSsidController = TextEditingController();
    _wifiPwdController = TextEditingController();
    _thingNameController = TextEditingController();
    // Send random data to trigger bonding
    context
        .read<TemperatureSensorInteractor>()
        .writeWifiSsid(deviceId: widget.deviceId, value: "123")
        .onError((error, stackTrace) => null);
  }

  @override
  void dispose() {
    _wifiSsidController.dispose();
    _wifiPwdController.dispose();
    _thingNameController.dispose();
    super.dispose();
  }

  void _startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _stopLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  void _displayError(String? message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _clearError() {
    _displayError(null);
  }

  /// Will return true if thingName is available
  Future<bool> _thingNameIsAvailable(String thingName) async {
    try {
      final things = await context.read<TemperatureApiService>().getAllThings();
      return !things.any((thing) => thing.thingName == thingName);
    } on ApiUnauthorizedException {
      _displayError("You are unauthorized to make this api request.");
    } on ApiUnknownException {
      _displayError("An unknown api error occurred.");
    }

    // if here means an exception occurred.
    return false;
  }

  Future<void> _sendProvisioningData() async {
    _startLoading();

    final wifiSsid = _wifiSsidController.text.trim();
    final wifiPwd = _wifiPwdController.text.trim();
    final thingName = _thingNameController.text.trim();

    if (wifiSsid.isEmpty || wifiPwd.isEmpty || thingName.isEmpty) {
      _displayError("Fields cannot be empty");
      _stopLoading();
      return;
    }

    // Check if thingName is already in use
    final thingNameIsAvailable = await _thingNameIsAvailable(thingName);
    if (!thingNameIsAvailable) {
      // Is already in use
      // TODO: CHANGE TO FIELD ERROR
      _displayError("Thing name is already in use, choose another one.");
      _stopLoading();
      return;
    }

    if (!context.mounted) {
      _stopLoading();
      return;
    }

    final interactor = context.read<TemperatureSensorInteractor>();

    try {
      final deviceId = widget.deviceId;
      await interactor.writeWifiSsid(deviceId: deviceId, value: wifiSsid);
      await interactor.writeWifiPwd(deviceId: deviceId, value: wifiPwd);
      await interactor.writeThingName(deviceId: deviceId, value: thingName);
      await interactor.informCompleteProvisioning(deviceId: deviceId);
      // TODO: Navigate away back to HomeScreen
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            BleProvisioningDataSentScreen.routeName, (route) => false);
      }
    } on BleWriteCharacteristicException {
      _displayError("An error occurred while trying to write to service.");
    } on BleWriteCharacteristicArgumentException {
      _displayError("All fields must be ascii.");
    } on BleWriteCharacteristicUnknownException {
      _displayError("An unknown error occurred, try again.");
    } finally {
      _stopLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BleAppBar(
        title: "Provision device",
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isLoading) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_errorMessage != null)
                        ErrorCard(message: _errorMessage!),
                      const MyDivider(),
                      WifiSsidTextFormField(
                        enabled: !_isLoading,
                        controller: _wifiSsidController,
                        labelText: "Wi-Fi SSID",
                      ),
                      const MyDivider(),
                      WifiPasswordTextFormField(
                        enabled: !_isLoading,
                        controller: _wifiPwdController,
                        labelText: "Wi-Fi password",
                      ),
                      const MyDivider(),
                      NonSecretTextFormField(
                        enabled: !_isLoading,
                        controller: _thingNameController,
                        labelText: "Thing name",
                        icon: Icons.device_thermostat_rounded,
                        validator: (String? value) {
                          if (value != null && value.isEmpty) {
                            return "Thing name cannot be empty";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const MyDivider(),
                      ElevatedButton(
                        // If loading disable button
                        onPressed: !_isLoading
                            ? () async {
                                _clearError();
                                await _sendProvisioningData();
                              }
                            : null,
                        child: const Text("Provision new device"),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
