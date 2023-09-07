import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/auth/auth_service.dart';

import 'amplifyconfiguration.dart';
import 'services/auth/auth_state.dart';
import 'ui/authenticator/authenticator.dart';
import 'ui/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();

  final auth = AuthService.fromCognito();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: auth),
        StreamProvider<AuthState?>(
            create: (_) => auth.state,
            initialData: const AuthState(
                isSignedIn: false
            ),
        ),
      ],
      child: const TemperatureApp(),
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
      home: const Authenticator(
        child: HomeScreen(title: "Home Page"),
      ),
    );
  }
}
