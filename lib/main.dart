import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/api/temperature_api_service.dart';
import 'package:temperature_app/ui/screens/ble/device_provisioning_screen.dart';

import 'amplifyconfiguration.dart';
import 'ui/authenticator/authenticator.dart';
import 'ui/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(
      AuthenticationProvider(
        child: Provider(
          create: (context) => TemperatureApiService(),
          child: const TemperatureApp(),
        ),
      ),
  );
}

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    await Amplify.addPlugin(auth);

    // call Amplify.configure to use the initialized categories in your app
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured Amplify.');
  } on Exception catch (e) {
    safePrint('An error occurred configuring Amplify: $e');
  }
}

class TemperatureApp extends StatelessWidget {
  const TemperatureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Will wrap every route in Authenticator Widget
      builder: (_, child) => Authenticator(child: child!),
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        switch(settings.name) {
          case DeviceProvisioningScreen.routeName:
            builder = (context) => const DeviceProvisioningScreen();
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
      home: const Authenticator(
        child: HomeScreen(title: "Home Page"),
      ),
    );
  }
}

