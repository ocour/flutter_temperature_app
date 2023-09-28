import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/ble/ble_connection_state.dart';
import 'package:temperature_app/services/ble/ble_connector_service.dart';
import 'package:temperature_app/services/ble/ble_device_connection_state.dart';
import 'package:temperature_app/services/ble/ble_device_interactor.dart';
import 'package:temperature_app/services/ble/ble_status_monitor_service.dart';
import 'package:temperature_app/services/ble/temperature_sensor/temperature_sensor_interactor.dart';
import 'package:temperature_app/services/logger_service.dart';
import 'package:temperature_app/ui/screens/ble/ble_provisioning_data_sent_screen.dart';
import 'package:temperature_app/ui/screens/ble/ble_status_screen.dart';

import 'ble_connect_to_device_screen.dart';
import 'ble_scan_screen.dart';

class DeviceProvisioningScreen extends StatefulWidget {
  const DeviceProvisioningScreen({super.key});

  static const String routeName = "/device-provision";

  @override
  State<DeviceProvisioningScreen> createState() =>
      _DeviceProvisioningScreenState();
}

class _DeviceProvisioningScreenState extends State<DeviceProvisioningScreen> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final LoggerService _logger;
  late final FlutterReactiveBle _ble;
  late final BleStatusMonitorService _bleStatusMonitor;
  late final BleConnectorService _connector;
  late final TemperatureSensorInteractor _interactor;
  final initialRoute = BleScanScreen.routeName;

  @override
  void initState() {
    super.initState();
    _logger = LoggerService();
    _ble = FlutterReactiveBle();
    _bleStatusMonitor = BleStatusMonitorService(ble: _ble);
    _interactor =
        TemperatureSensorInteractor(ble: _ble, logMessage: _logger.log);
    _connector = BleConnectorService(
        ble: _ble, logMessage: _logger.log, interactor: _interactor);
  }

  @override
  void dispose() {
    _connector.dispose();
    super.dispose();
  }

  /// Will generate [BleScanScreen] as the initial route, this is to override
  /// the default defaultGenerateInitialRoutes that will
  /// implement "deep linking" which is not something we want
  List<Route<dynamic>> defaultGenerateInitialRoutes(
    NavigatorState navigator,
    String initialRouteName,
  ) {
    List<MaterialPageRoute> routes = [];
    routes.add(MaterialPageRoute(
        builder: (_) => BleScanScreen(onPop: Navigator.of(context).pop)));
    return routes;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _logger),
        Provider.value(value: _ble),
        Provider.value(value: _connector),
        Provider.value(value: _interactor),
        StreamProvider<BleStatus?>(
            create: (_) => _bleStatusMonitor.state,
            initialData: BleStatus.unknown),
        StreamProvider<BleConnectionState?>(
          create: (_) => _connector.state,
          initialData: const BleConnectionState(
            deviceId: "Unknown device",
            connectionState: BleDeviceConnectionState.none,
            failure: null,
          ),
        ),
      ],
      child: WillPopScope(
        onWillPop: () async {
          if (_navigatorKey.currentState?.canPop() ?? false) {
            _navigatorKey.currentState!.pop();
            return false;
          }
          return true;
        },
        child: Consumer<BleStatus?>(
          builder: (_, status, __) {
            if (status != BleStatus.ready) {
              return BleStatusScreen(status: status ?? BleStatus.unknown);
            } else {
              return Navigator(
                key: _navigatorKey,
                initialRoute: initialRoute,
                onGenerateInitialRoutes: defaultGenerateInitialRoutes,
                onGenerateRoute: (settings) {
                  WidgetBuilder builder;
                  switch (settings.name) {
                    case BleScanScreen.routeName:
                      builder = (_) => BleScanScreen(
                            // Pass this here to get access to the [context] outside
                            // of this [Navigator]. This is required to pop out of
                            // this nested [Navigator]
                            onPop: Navigator.of(context).pop,
                          );
                      break;
                    case BleConnectToDeviceScreen.routeName:
                      final device = settings.arguments as DiscoveredDevice;
                      builder = (_) => BleConnectToDeviceScreen(device: device);
                      break;
                    case BleProvisioningDataSentScreen.routeName:
                      builder = (_) => BleProvisioningDataSentScreen(
                            onDone: Navigator.of(context).pop,
                          );
                      break;
                    default:
                      throw Exception('Invalid route: ${settings.name}');
                  }
                  return MaterialPageRoute(
                      builder: builder, settings: settings);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
