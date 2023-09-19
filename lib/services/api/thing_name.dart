import 'package:flutter/foundation.dart';

import 'json_keys.dart';

@immutable
class ThingName {
  final String thingName;

  const ThingName({required this.thingName});

  ThingName.fromJson(Map<String, dynamic> json)
      : thingName = json[thingNameKey]["S"];

  Map<String, dynamic> toJson() => {
    thingNameKey: { "S": thingName },
  };

  @override
  String toString() => "ThingName(thingName: $thingName)";

  @override
  bool operator ==(Object other) =>
      other is ThingName &&
          other.runtimeType == runtimeType &&
          other.thingName == thingName;

  @override
  int get hashCode => thingName.hashCode;
}