import "dart:developer" as developer show log;

class LoggerService {

  void log({
    required String name,
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final time = DateTime.now();
    developer.log(
      "$time - $message",
      name: name,
      time: time,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
