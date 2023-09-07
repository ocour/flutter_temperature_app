import 'package:temperature_app/services/auth/auth_state.dart';
import 'package:temperature_app/services/auth/cognito_auth_provider.dart';

import 'auth_next_step.dart';
import 'auth_provider.dart';

class AuthService extends AuthProvider {
  AuthService({required this.provider});

  factory AuthService.fromCognito() {
    return AuthService(provider: CognitoAuthProvider());
  }

  final AuthProvider provider;

  @override
  Stream<AuthState> get state => provider.state;

  @override
  bool get isSignedIn => provider.isSignedIn;


  @override
  Future<void> initialize() {
    return provider.initialize();
  }

  @override
  Future<AuthNextStep> confirmNewPassword(String newPassword) {
    return provider.confirmNewPassword(newPassword);
  }

  @override
  Future<AuthNextStep> signIn({
    required String username,
    required String password,
  }) {
    return provider.signIn(username: username, password: password);
  }

  @override
  Future<void> signOut() {
    return provider.signOut();
  }


  @override
  Future<void> dispose() {
    return provider.dispose();
  }
}
