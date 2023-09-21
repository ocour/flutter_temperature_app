import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart'
    as cognito
    show NotAuthorizedServiceException, UserNotFoundException, AuthException, CognitoFailedSignOut, SignedOutException;
import 'package:amplify_flutter/amplify_flutter.dart'
    as amplify
    show Amplify, AuthHubEvent, AuthHubEventType, HubChannel, safePrint;

import 'package:temperature_app/services/auth/auth_exceptions.dart';
import 'package:temperature_app/services/auth/auth_provider.dart';
import 'package:temperature_app/services/auth/auth_state.dart';

import 'auth_next_step.dart';

class CognitoAuthProvider extends AuthProvider {
  @override
  Future<void> initialize() async {
    await _authEventSubscription?.cancel();
    // Get initial SignedIn state
    await _pushState();
    // TODO: REMOVE PRINT
    print("CognitoAuthProvider: initialize()");
    print("SignedIn: ${await _isSignedIn}");

    // Subscribe to SingIn and SingOut events
    _authEventSubscription =
        amplify.Amplify.Hub.listen(amplify.HubChannel.Auth, (amplify.AuthHubEvent event) async {
      switch (event.type) {
        case amplify.AuthHubEventType.signedIn:
          amplify.safePrint('User is signed in.');
          await _pushState();
          break;
        case amplify.AuthHubEventType.signedOut:
          amplify.safePrint('User is signed out.');
          await _pushState();
          break;
        case amplify.AuthHubEventType.sessionExpired:
          amplify.safePrint('The session has expired.');
          await _pushState();
          break;
        case amplify.AuthHubEventType.userDeleted:
          amplify.safePrint('The user has been deleted.');
          await _pushState();
          break;
      }
    });
  }

  StreamSubscription<amplify.AuthHubEvent>? _authEventSubscription;
  final _stateController = StreamController<AuthState>();

  @override
  Stream<AuthState> get state => _stateController.stream;

  Future<bool> get _isSignedIn async {
    try {
      final result = await amplify.Amplify.Auth.fetchAuthSession();
      return result.isSignedIn;
    } on cognito.SignedOutException {
      return false;
    }
  }

  @override
  Future<bool> get isSignedIn async => await _isSignedIn;

  // Push state to stream
  Future<void> _pushState() async {
    _stateController.add(
      AuthState(isSignedIn: await _isSignedIn),
    );
  }

  @override
  Future<AuthNextStep> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final result = await amplify.Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      // amplify.safePrint('Result: ${result.nextStep}');
      return AuthNextStep.fromAuthSignInStep(step: result.nextStep.signInStep);
    } on cognito.UserNotFoundException catch (e) {
      throw AuthUserNotFoundException(message: e.message);
    } on cognito.NotAuthorizedServiceException catch (e) {
      throw AuthWrongPasswordException(message: e.message);
    } on cognito.AuthException catch (e) {
      throw AuthUnknownException(message: e.message);
    }
  }

  @override
  Future<void> signOut() async {
    final result = await amplify.Amplify.Auth.signOut();
    if (result is cognito.CognitoFailedSignOut) {
      amplify.safePrint('Error signing user out: ${result.exception.message}');
    }
  }

  @override
  Future<AuthNextStep> confirmNewPassword(String newPassword) async {
    try {
      final result = await amplify.Amplify.Auth.confirmSignIn(
        confirmationValue: newPassword,
      );
      // amplify.safePrint('Result: ${result.nextStep}');
      return AuthNextStep.fromAuthSignInStep(step: result.nextStep.signInStep);
    } on cognito.AuthException catch (e) {
      amplify.safePrint('Error confirming new password: ${e.message}');
      amplify.safePrint('Error type: ${e.runtimeType}');
      throw AuthUnknownException(message: e.message);
    }
  }

  @override
  Future<void> dispose() async {
    await _authEventSubscription?.cancel();
    await _stateController.close();
  }
}
