import 'dart:async';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {

  StreamSubscription<AuthHubEvent>? _authEventSubscription;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  Future<void> initialize() async {
    // Get initial SignedIn state
    await updateUserAuthStatus();
    print("SignedIn: $_isSignedIn");

    // Subscribe to SingIn and SingOut events
    _authEventSubscription = Amplify.Hub.listen(HubChannel.Auth, (AuthHubEvent event) async {
      switch (event.type) {
        case AuthHubEventType.signedIn:
          safePrint('User is signed in.');
          await updateUserAuthStatus();
          break;
        case AuthHubEventType.signedOut:
          safePrint('User is signed out.');
          await updateUserAuthStatus();
          break;
        case AuthHubEventType.sessionExpired:
          safePrint('The session has expired.');
          await updateUserAuthStatus();
          break;
        case AuthHubEventType.userDeleted:
          safePrint('The user has been deleted.');
          await updateUserAuthStatus();
          break;
      }
    });
  }

  Future<void> updateUserAuthStatus({bool? isSignedIn}) async {
    if(isSignedIn == null) {
      final result = await Amplify.Auth.fetchAuthSession();
      _isSignedIn = result.isSignedIn;
      notifyListeners();
    } else {
      _isSignedIn = isSignedIn;
      notifyListeners();
    }
  }

  Future<AuthSignInStep> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      safePrint('isSignedIn: ${result.isSignedIn}');
      safePrint('Result: ${result.nextStep}');

      await updateUserAuthStatus(isSignedIn: result.isSignedIn);
      return result.nextStep.signInStep;
    } on AuthException catch (e) {
      safePrint('Error signing in: ${e.message}');
      rethrow;
    }
  }

  Future<void> confirmNewPassword(String newPassword) async {
    try {
      final result = await Amplify.Auth.confirmSignIn(
        confirmationValue: newPassword,
      );
      safePrint('isSignedIn: ${result.isSignedIn}');
      safePrint('Result: ${result.nextStep}');

      await updateUserAuthStatus(isSignedIn: result.isSignedIn);
    } on AuthException catch (e) {
      safePrint('Error confirming new password: ${e.message}');
      rethrow;
    }
  }

  Future<void> signOut() async {
    final result = await Amplify.Auth.signOut();
    if (result is CognitoFailedSignOut) {
      safePrint('Error signing user out: ${result.exception.message}');
    }
  }

  @override
  Future<void> dispose() async {
    await _authEventSubscription?.cancel();
    super.dispose();
  }
}
