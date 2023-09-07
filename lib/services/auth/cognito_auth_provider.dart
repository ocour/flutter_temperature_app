import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart'
    as cognito
    show NotAuthorizedServiceException, UserNotFoundException, AuthException, CognitoFailedSignOut;
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
    // Get initial SignedIn state
    await _updateUserAuthStatus();
    // TODO: REMOVE PRINT
    print("SignedIn: $_isSignedIn");

    // Subscribe to SingIn and SingOut events
    _authEventSubscription =
        amplify.Amplify.Hub.listen(amplify.HubChannel.Auth, (amplify.AuthHubEvent event) async {
      switch (event.type) {
        case amplify.AuthHubEventType.signedIn:
          amplify.safePrint('User is signed in.');
          await _updateUserAuthStatus();
          break;
        case amplify.AuthHubEventType.signedOut:
          amplify.safePrint('User is signed out.');
          await _updateUserAuthStatus();
          break;
        case amplify.AuthHubEventType.sessionExpired:
          amplify.safePrint('The session has expired.');
          await _updateUserAuthStatus();
          break;
        case amplify.AuthHubEventType.userDeleted:
          amplify.safePrint('The user has been deleted.');
          await _updateUserAuthStatus();
          break;
      }
    });
  }

  StreamSubscription<amplify.AuthHubEvent>? _authEventSubscription;
  final _stateController = StreamController<AuthState>();

  @override
  Stream<AuthState> get state => _stateController.stream;

  bool _isSignedIn = false;

  @override
  bool get isSignedIn => _isSignedIn;

  void _pushState() {
    _stateController.add(
      AuthState(isSignedIn: _isSignedIn),
    );
  }

  /// Updates [_isSignedIn] variable and adds state to stream
  ///
  /// If [isSignedIn] parameter is supplied [_isSignedIn] will be set to it,
  /// otherwise if no parameter is supplied, fetch [AuthSession] and set its
  /// [isSignedIn] to our [_isSignedIn]
  Future<void> _updateUserAuthStatus({bool? isSignedIn}) async {
    if (isSignedIn == null) {
      final result = await amplify.Amplify.Auth.fetchAuthSession();
      _isSignedIn = result.isSignedIn;
      _pushState();
    } else {
      _isSignedIn = isSignedIn;
      _pushState();
    }
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
      amplify.safePrint('Result: ${result.nextStep}');
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
      amplify.safePrint('Result: ${result.nextStep}');
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
