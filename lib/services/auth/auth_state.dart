import 'package:flutter/foundation.dart';

@immutable
class AuthState {
  final bool isSignedIn;

  const AuthState({required this.isSignedIn});
}