import 'package:temperature_app/services/reactive_state.dart';

import 'auth_next_step.dart';
import 'auth_state.dart';

abstract class AuthProvider extends ReactiveState<AuthState> {
  Future<void> initialize();

  Future<bool> get isSignedIn;

  @override
  Stream<AuthState> get state;

  Future<AuthNextStep> signIn({
    required String username,
    required String password,
  });

  Future<void> signOut();

  Future<AuthNextStep> confirmNewPassword(String newPassword);

  Future<void> dispose();
}
