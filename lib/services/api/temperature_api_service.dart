import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:temperature_app/backend.dart';
import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:temperature_app/services/api/exceptions.dart';
import 'package:temperature_app/services/api/temperature_data.dart';

import 'thing_name.dart';

class TemperatureApiService {

  /// Get [idToken] that will be used for authorization when supplied inside
  /// header of http request
  Future<String> _getIdToken() async {
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    final authSession = await cognitoPlugin.fetchAuthSession();

    // This idToken will be used by the api for authorization
    final idToken = authSession.userPoolTokensResult.value.idToken.toJson();
    return idToken;
  }

  /// Will fetch all registered things, will return a list of all unique
  /// thing-names
  Future<List<ThingName>> getAllThings() async {
    try {
      // This idToken will be used by the api for authorization
      final idToken = await _getIdToken();

      final url = Uri.https(ENDPOINT, "$STAGE/things");
      // print("URL: $url");

      final response = await http.get(url, headers: {
        "Authorization": idToken
      });

      if(response.statusCode == 401) {
        throw ApiUnauthorizedException();
      } else if(response.statusCode != 200) {
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
      final idToken = await _getIdToken();

      final thingNameString = thingName.thingName;

      final url = Uri.https(ENDPOINT, "$STAGE/temperature/$thingNameString");

      final response = await http.get(url, headers: {
        "Authorization": idToken
      });

      if(response.statusCode == 401) {
        throw ApiUnauthorizedException();
      } else if(response.statusCode != 200) {
        throw ApiUnknownException();
      }

      // Request succeeded, parse response
      final Map<String, dynamic> parsed = jsonDecode(response.body);
      final items = parsed["Items"];
      final temperatureData = items.map((item) => TemperatureData.fromJson(item));

      return List<TemperatureData>.from(temperatureData);
    } on ApiUnauthorizedException {
      rethrow;
    } catch (e) {
      throw ApiUnknownException();
    }
  }
}