import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/ble/exceptions/exceptions.dart';
import 'package:temperature_app/services/ble/temperature_sensor/temperature_sensor_interactor.dart';
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

  Future<void> _checkThingNameAvailability() async {
    // TODO:
  }

  Future<void> _sendProvisioningData() async {
    _startLoading();

    final wifiSsid = _wifiSsidController.text;
    final wifiPwd = _wifiPwdController.text;
    final thingName = _thingNameController.text;

    if(wifiSsid.isEmpty || wifiPwd.isEmpty || thingName.isEmpty) {
      _displayError("Fields cannot be empty");
      _stopLoading();
      return;
    }

    // TODO: CHECK THAT THING-NAME IS FREE WITH API CALL

    final interactor = context.read<TemperatureSensorInteractor>();

    try {
      await interactor.writeWifiSsid(deviceId: widget.deviceId, value: wifiSsid);
      await interactor.writeWifiPwd(deviceId: widget.deviceId, value: wifiPwd);
      await interactor.writeThingName(deviceId: widget.deviceId, value: thingName);
      await interactor.informCompleteProvisioning(deviceId: widget.deviceId);
    } on BleWriteCharacteristicException {
      _displayError("An error occurred while trying to write to service");
    } on BleWriteCharacteristicArgumentException {
      _displayError("All fields must be ascii");
    } on BleWriteCharacteristicUnknownException {
      _displayError("An unknown error occurred");
    } finally {
      _stopLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TemperatureAppAppBar(title: "Provision device"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if(_isLoading) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if(_errorMessage != null) ErrorCard(message: _errorMessage!),
                      const MyDivider(),
                      WifiSsidTextFormField(
                        enabled: true,
                        controller: _wifiSsidController,
                        labelText: "Wi-Fi SSID",
                      ),
                      const MyDivider(),
                      WifiPasswordTextFormField(
                        enabled: true,
                        controller: _wifiPwdController,
                        labelText: "Wi-Fi password",
                      ),
                      const MyDivider(),
                      NonSecretTextFormField(
                        enabled: true,
                        controller: _thingNameController,
                        labelText: "Thing name",
                        icon: Icons.device_thermostat_rounded,
                        validator: (String? value) {
                          if(value != null && value.isEmpty) {
                            return "Thing name cannot be empty";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const MyDivider(),
                      ElevatedButton(
                          onPressed: () async {
                            _clearError();
                            await _sendProvisioningData();
                          },
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
