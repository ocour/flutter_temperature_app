import 'package:flutter/foundation.dart';

import 'json_keys.dart';
import 'thing_name.dart';

@immutable
class TemperatureData {
  const TemperatureData({
    required this.temperature,
    required this.timeStamp,
    required this.thingName,
  });

  final ThingName thingName;
  final int temperature;
  final DateTime timeStamp;

  TemperatureData.fromJson(Map<String, dynamic> json)
      : thingName = ThingName.fromJson(json),
        temperature = int.parse(json[temperatureKey]["N"]),

        /// [timestamp] is stored as seconds in database, as such to convert it
        /// using the [DateTime.fromMillisecondsSinceEpoch] multiply [timestamp]
        /// with 1000 to get milliseconds
        timeStamp = DateTime.fromMillisecondsSinceEpoch(
            int.parse(json[timestampKey]["S"]) * 1000,
            isUtc: true);

  Map<String, dynamic> toJson() => {
        thingNameKey: {"S": thingName.thingName},
        temperatureKey: {"N": temperature},
        timestampKey: {"S": timeStamp},
      };

  @override
  String toString() =>
      "TemperatureData($thingName, temperature: $temperature, timestamp: $timeStamp)";
}
