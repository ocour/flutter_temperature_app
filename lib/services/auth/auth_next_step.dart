import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/foundation.dart';

enum AuthStep {
  /// The sign-in is not complete and must be confirmed with the user's new
  /// password.
  confirmSignInWithNewPassword,

  /// The sign-in is complete.
  done,

  /// Step not implemented
  notImplemented
}

@immutable
class AuthNextStep {
  const AuthNextStep({required this.step});

  final AuthStep step;

  factory AuthNextStep.fromAuthSignInStep({required AuthSignInStep step}) {
    late final AuthStep authStep;

    switch(step) {
      case AuthSignInStep.confirmSignInWithNewPassword:
        authStep = AuthStep.confirmSignInWithNewPassword;
      case AuthSignInStep.done:
        authStep = AuthStep.done;
      default:
        authStep = AuthStep.notImplemented;
    }

    return AuthNextStep(step: authStep);
  }
}