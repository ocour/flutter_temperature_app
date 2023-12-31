import 'dart:collection';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:temperature_app/backend.dart';
import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:temperature_app/services/api/exceptions.dart';
import 'package:temperature_app/services/api/temperature_data.dart';
import 'package:temperature_app/services/auth/auth_service.dart';

import 'thing_name.dart';

class TemperatureApiService {
  TemperatureApiService({required AuthService authService})
      : _authService = authService;

  final AuthService _authService;

  /// Will fetch all registered things, will return a list of all unique
  /// thing-names
  Future<List<ThingName>> getAllThings() async {
    try {
      // This idToken will be used by the api for authorization
      final idToken = await _authService.fetchIdToken();

      final url = Uri.https(ENDPOINT, "$STAGE/things");

      final response = await http.get(url, headers: {"Authorization": idToken});

      if (response.statusCode == 401) {
        throw ApiUnauthorizedException();
      } else if (response.statusCode != 200) {
        throw ApiUnknownException();
      }

      // Request succeeded, parse response
      final Map<String, dynamic> parsed = jsonDecode(response.body);
      final items = parsed["Items"].toList();
      final thingNames = items.map((item) => ThingName.fromJson(item));
      final thingNameList = List<ThingName>.from(thingNames);
      final uniqueThingNames = Set<ThingName>.from(thingNameList);

      return uniqueThingNames.toList();
    } on ApiUnauthorizedException {
      rethrow;
    } catch (e) {
      throw ApiUnknownException();
    }
  }

  /// Get temperature data of [thingName]
  Future<List<TemperatureData>> getTemperatureData(ThingName thingName) async {
    try {
      // This idToken will be used by the api for authorization
      final idToken = await _authService.fetchIdToken();

      final thingNameString = thingName.thingName;

      final url = Uri.https(ENDPOINT, "$STAGE/temperature/$thingNameString");

      final response = await http.get(url, headers: {"Authorization": idToken});

      if (response.statusCode == 401) {
        throw ApiUnauthorizedException();
      } else if (response.statusCode != 200) {
        throw ApiUnknownException();
      }

      // Request succeeded, parse response
      final Map<String, dynamic> parsed = jsonDecode(response.body);
      final items = parsed["Items"];
      final temperatureData =
          items.map((item) => TemperatureData.fromJson(item));

      final data = List<TemperatureData>.from(temperatureData);
      // Sort list from newest to oldest
      data.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));

      return data;
    } on ApiUnauthorizedException {
      rethrow;
    } catch (e) {
      throw ApiUnknownException();
    }
  }
}
