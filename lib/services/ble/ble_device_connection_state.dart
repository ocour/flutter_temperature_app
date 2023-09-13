enum BleDeviceConnectionState {
  /// Currently establishing a connection.
  connecting,

  /// Connection is established.
  connected,

  /// Terminating the connection.
  disconnecting,

  /// Device is disconnected.
  disconnected,

  /// Device has not been connected at all, default state
  none,

  /// Device has been connected to and it support required services
  connectedAndDoesSupportServices,

  /// Device has been connected to but it does NOT support required services
  connectedButDoesNotSupportServices,
}