import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/ui/authenticator/ConfirmNewPasswordScreen.dart';
import 'package:temperature_app/ui/authenticator/SignOutScreen.dart';

import '../../amplifyconfiguration.dart';
import '../../services/AuthService.dart';
import 'SignInScreen.dart';

class Authenticator extends StatefulWidget {
  const Authenticator({super.key, required this.child});

  final Widget child;

  @override
  State<Authenticator> createState() => _AuthenticatorState();
}

class _AuthenticatorState extends State<Authenticator> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<AuthService>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
        builder: (_, auth, __) {
          if(auth.isSignedIn) {
            return widget.child;
          } else {
            return Navigator(
              initialRoute: /* SignInScreen.routeName */ ConfirmNewPasswordScreen.routeName,
              onGenerateRoute: (settings) {
                WidgetBuilder builder;
                switch(settings.name) {
                  case SignInScreen.routeName:
                    builder = (context) => const SignInScreen();
                    break;
                  case SignOutScreen.routeName:
                    builder = (context) => const SignOutScreen();
                    break;
                  case ConfirmNewPasswordScreen.routeName:
                    builder = (context) => const ConfirmNewPasswordScreen();
                    break;
                  default:
                    throw Exception('Invalid route: ${settings.name}');
                }
                return MaterialPageRoute(builder: builder, settings: settings);
              },
            );
          }
        },
    );
  }
}
