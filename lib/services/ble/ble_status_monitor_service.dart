import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../reactive_state.dart';

class BleStatusMonitorService implements ReactiveState<BleStatus> {
  BleStatusMonitorService({ required FlutterReactiveBle ble}) : _ble = ble;

  final FlutterReactiveBle _ble;

  @override
  Stream<BleStatus> get state => _ble.statusStream;
}