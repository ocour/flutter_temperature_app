import 'package:flutter/foundation.dart';

@immutable
class AuthException implements Exception {
  final String message;

  const AuthException({required this.message});
}

// Username cannot be found in database
class AuthUserNotFoundException extends AuthException {
  const AuthUserNotFoundException({required super.message});
}

// Wrong password on signIn
class AuthWrongPasswordException extends AuthException {
  const AuthWrongPasswordException({required super.message});
}

// Unknown exception
class AuthUnknownException extends AuthException {
  const AuthUnknownException({required super.message});
}