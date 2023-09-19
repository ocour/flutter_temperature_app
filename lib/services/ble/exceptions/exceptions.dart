// Thrown if exception occurs while discovering services
class DiscoverServicesExceptions implements Exception {}

// Throws if writing to characteristic fails
class BleWriteCharacteristicException implements Exception {
  final String message;

  BleWriteCharacteristicException(this.message);
}

// Throws if value that will be written to characteristic is not valid ascii
class BleWriteCharacteristicArgumentException implements Exception {}

// Thrown when an unknown error occurs while writing to characteristic
class BleWriteCharacteristicUnknownException implements Exception {}
