import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/ble/ble_connection_state.dart';
import 'package:temperature_app/services/ble/ble_device_connection_state.dart';
import 'package:temperature_app/ui/utils/divider.dart';
import 'package:temperature_app/ui/utils/temperature_app_app_bar.dart';

import '../../../services/ble/temperature_sensor/temperature_sensor_interactor.dart';
import 'ble_app_bar.dart';

class BleDeviceConnectionStateBody extends StatelessWidget {
  const BleDeviceConnectionStateBody(
      {super.key, required this.state});

  final BleConnectionState state;

  Icon getErrorIcon(BuildContext context) => Icon(
        Icons.error_outline_rounded,
        size: 32.0,
        color: Theme.of(context).colorScheme.error,
      );

  final infoIcon = const Icon(
    Icons.info_outline_rounded,
    size: 32.0,
  );

  final successIcon = const Icon(
    Icons.check_circle_outline_rounded,
    size: 32.0,
  );

  Widget determineWidget(BuildContext context, BleConnectionState state) {
    switch (state.connectionState) {
      case BleDeviceConnectionState.none:
        return LoadingWidget(
          title: "Preparing to connect to device",
          icon: infoIcon,
        );
      case BleDeviceConnectionState.disconnected:
        final failure = state.failure;
        if (failure != null) {
          return DisconnectInfoWidget(
            title: "Disconnected with an error.",
            errorText: failure.message,
          );
        } else {
          return const DisconnectInfoWidget(title: "Disconnected");
        }
      case BleDeviceConnectionState.disconnecting:
        return LoadingWidget(
          title: "Disconnecting from device",
          icon: infoIcon,
        );
      case BleDeviceConnectionState.connecting:
        return LoadingWidget(title: "Connecting to device", icon: infoIcon);
      case BleDeviceConnectionState.connected:
        return LoadingWidget(
          title: "Connected, retrieving services",
          icon: successIcon,
        );
      case BleDeviceConnectionState.connectedAndDoesSupportServices:
        return LoadingWidget(
          title: "Connected, device does support required services",
          subTitle: "Navigating to provisioning screen",
          icon: successIcon,
        );
      case BleDeviceConnectionState.connectedButDoesNotSupportServices:
        return LoadingWidget(
          title: "Connected, device does not support required services",
          subTitle: "Disconnecting from device...",
          icon: getErrorIcon(context),
        );
      default:
        return const Text("Unknown state");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BleAppBar(
          title: "Connection status",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: determineWidget(
            context,
            state,
          ),
        ),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    required this.title,
    required this.icon,
    this.subTitle = "",
  });

  final Icon icon;
  final String title;
  final String subTitle;

  Widget subTitleWidget(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MyDivider(),
          Text(
            subTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        const MyDivider(),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (subTitle.isNotEmpty) subTitleWidget(context),
        const MyDivider(),
        const CircularProgressIndicator(),
      ],
    );
  }
}

class DisconnectInfoWidget extends StatelessWidget {
  const DisconnectInfoWidget({super.key, required this.title, this.errorText});

  final String title;
  final String? errorText;

  String? get _errorText {
    final errorText = this.errorText;
    if (errorText != null) {
      return errorText.isEmpty
          ? "Error: An unknown error"
          : "Error: $errorText";
    } else {
      return errorText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 32.0,
          color:
              _errorText != null ? Theme.of(context).colorScheme.error : null,
        ),
        const MyDivider(),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const MyDivider(),
        Text(
          _errorText ?? "",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
