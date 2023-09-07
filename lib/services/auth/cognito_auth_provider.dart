import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart'
    as cognito
    show NotAuthorizedServiceException, UserNotFoundException, AuthException;
import 'package:amplify_flutter/amplify_flutter.dart'
    as amplify
    show Amplify, AuthHubEvent, AuthHubEventType, AuthSignInStep, HubChannel, safePrint;
import 'package:temperature_app/services/auth/auth_exceptions.dart';
import 'package:temperature_app/services/auth/auth_provider.dart';
import 'package:temperature_app/services/auth/auth_state.dart';

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

  /// Updates [_isSignedIn] variable
  ///
  /// if [isSignedIn] parameter is supplied [_isSignedIn] will be set to it,
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
      await _updateUserAuthStatus(isSignedIn: result.isSignedIn);
      return _returnAuthNextStep(result.nextStep.signInStep);
    } on cognito.UserNotFoundException catch (e) {
      throw AuthUserNotFoundException(message: e.message);
    } on cognito.NotAuthorizedServiceException catch (e) {
      throw AuthWrongPasswordException(message: e.message);
    } on cognito.AuthException catch (e) {
      throw AuthUnknownException(message: e.message);
    }
  }

  AuthNextStep _returnAuthNextStep(amplify.AuthSignInStep nextStep) {
    switch(nextStep) {
      case amplify.AuthSignInStep.confirmSignInWithNewPassword:
        return AuthNextStep.confirmSignInWithNewPassword;
      case amplify.AuthSignInStep.done:
        return AuthNextStep.done;
      default:
        return AuthNextStep.notImplemented;
    }
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<void> confirmNewPassword(String newPassword) {
    // TODO: implement confirmNewPassword
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() async {
    await _authEventSubscription?.cancel();
    await _stateController.close();
  }
}
