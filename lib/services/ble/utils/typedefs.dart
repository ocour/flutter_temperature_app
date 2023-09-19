
typedef LogMessage = void Function({
  required String name,
  required String message,
  Object? error,
  StackTrace? stackTrace,
});