import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/ui/authenticator/confirm_new_password_screen.dart';
import 'package:temperature_app/ui/authenticator/sign_out_screen.dart';

import '../../services/auth/auth_service.dart';
import '../../services/auth/auth_state.dart';
import 'sign_in_screen.dart';

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
    return Consumer<AuthState?>(
        builder: (_, state, __) {
          if(state?.isSignedIn ?? false) {
            return widget.child;
          } else {
            return Navigator(
              initialRoute: SignInScreen.routeName,
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