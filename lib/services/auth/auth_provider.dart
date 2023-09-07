import 'package:flutter/cupertino.dart';
import 'package:temperature_app/services/reactive_state.dart';

import 'auth_state.dart';

abstract class AuthProvider extends ReactiveState<AuthState> {
  Future<void> initialize();

  bool get isSignedIn;

  @override
  Stream<AuthState> get state;

  Future<AuthNextStep> signIn({
    required String username,
    required String password,
  });

  Future<void> signOut();

  Future<void> confirmNewPassword(String newPassword);

  Future<void> dispose();
}

enum AuthNextStep {
  /// The sign-in is not complete and must be confirmed with the user's new
  /// password.
  confirmSignInWithNewPassword,

  /// The sign-in is complete.
  done,

  /// Step not implemented
  notImplemented
}
