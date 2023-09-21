import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/ui/authenticator/confirm_new_password_screen.dart';
import 'package:temperature_app/ui/authenticator/sign_out_screen.dart';

import '../../services/auth/auth_service.dart';
import '../../services/auth/auth_state.dart';
import 'loading_screen.dart';
import 'sign_in_screen.dart';

/// Wraps child to prevent unauthenticated access to it
///
/// TODO: Example usages
class Authenticator extends StatefulWidget {
  const Authenticator({super.key, required this.child});

  final Widget child;

  @override
  State<Authenticator> createState() => _AuthenticatorState();
}

class _AuthenticatorState extends State<Authenticator> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
  }

  /// Will generate [SignInScreen] as the initial route, this is to override
  /// the default defaultGenerateInitialRoutes that will
  /// implement "deep linking" which is not something we want
  List<Route<dynamic>> defaultGenerateInitialRoutes(
    NavigatorState navigator,
    String initialRouteName,
  ) {
    List<MaterialPageRoute> routes = [];
    routes.add(MaterialPageRoute(builder: (context) => const SignInScreen()));
    return routes;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState?>(
      builder: (_, state, __) {
        if(state?.isSignedIn == null) {
          return const LoadingScreen();
        }
        else if (state?.isSignedIn ?? false) {
          return widget.child;
        } else {
          return Navigator(
            key: _navigatorKey,
            initialRoute: SignInScreen.routeName,
            onGenerateInitialRoutes: defaultGenerateInitialRoutes,
            onGenerateRoute: (settings) {
              WidgetBuilder builder;
              switch (settings.name) {
                case SignInScreen.routeName:
                  builder = (context) => const SignInScreen();
                  break;
                // TODO: REMOVE SIGN OUT SCREEN
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

/// Provider for AuthService and AuthState stream
///
/// TODO: Example usages
class AuthenticationProvider extends StatefulWidget {
  const AuthenticationProvider({super.key, required this.child});

  final Widget child;

  @override
  State<AuthenticationProvider> createState() => _AuthenticationProviderState();
}

class _AuthenticationProviderState extends State<AuthenticationProvider> {
  final auth = AuthService.fromCognito();

  @override
  void initState() {
    super.initState();
    auth.initialize();
  }

  @override
  void dispose() {
    auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: auth),
        StreamProvider<AuthState?>(
          create: (_) => auth.state,
          initialData: const AuthState(isSignedIn: null),
        ),
      ],
      child: widget.child,
    );
  }
}
