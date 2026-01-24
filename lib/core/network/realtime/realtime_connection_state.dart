/// Real-time connection state definitions.
///
/// Defines the possible states of a real-time connection
/// for use in UI and connection management.
library;

import 'package:equatable/equatable.dart';

/// Enum representing the current state of a real-time connection.
enum RealtimeConnectionStatus {
  /// Initial state, not yet connected.
  disconnected,

  /// Actively attempting to establish a connection.
  connecting,

  /// Successfully connected and ready to send/receive messages.
  connected,

  /// Connection lost, attempting to reconnect.
  reconnecting,

  /// Connection failed after all retry attempts.
  failed,
}

/// Extension on [RealtimeConnectionStatus] for convenience methods.
extension RealtimeConnectionStatusX on RealtimeConnectionStatus {
  /// Whether the connection is active and ready.
  bool get isConnected => this == RealtimeConnectionStatus.connected;

  /// Whether a connection attempt is in progress.
  bool get isConnecting =>
      this == RealtimeConnectionStatus.connecting ||
      this == RealtimeConnectionStatus.reconnecting;

  /// Whether the connection is not active.
  bool get isDisconnected =>
      this == RealtimeConnectionStatus.disconnected ||
      this == RealtimeConnectionStatus.failed;

  /// Human-readable description of the state.
  String get description {
    switch (this) {
      case RealtimeConnectionStatus.disconnected:
        return 'Disconnected';
      case RealtimeConnectionStatus.connecting:
        return 'Connecting...';
      case RealtimeConnectionStatus.connected:
        return 'Connected';
      case RealtimeConnectionStatus.reconnecting:
        return 'Reconnecting...';
      case RealtimeConnectionStatus.failed:
        return 'Connection failed';
    }
  }
}

/// Immutable state class for real-time connection.
///
/// Contains the current status, error information, and retry metadata.
class RealtimeConnectionState extends Equatable {
  /// Creates a new connection state.
  const RealtimeConnectionState({
    this.status = RealtimeConnectionStatus.disconnected,
    this.error,
    this.retryCount = 0,
    this.lastConnectedAt,
    this.lastDisconnectedAt,
  });

  /// Creates an initial disconnected state.
  const RealtimeConnectionState.initial()
      : status = RealtimeConnectionStatus.disconnected,
        error = null,
        retryCount = 0,
        lastConnectedAt = null,
        lastDisconnectedAt = null;

  /// Current connection status.
  final RealtimeConnectionStatus status;

  /// Error message if connection failed.
  final String? error;

  /// Number of reconnection attempts made.
  final int retryCount;

  /// Timestamp of last successful connection.
  final DateTime? lastConnectedAt;

  /// Timestamp of last disconnection.
  final DateTime? lastDisconnectedAt;

  /// Creates a copy with updated values.
  RealtimeConnectionState copyWith({
    RealtimeConnectionStatus? status,
    String? error,
    int? retryCount,
    DateTime? lastConnectedAt,
    DateTime? lastDisconnectedAt,
    bool clearError = false,
  }) {
    return RealtimeConnectionState(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      retryCount: retryCount ?? this.retryCount,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      lastDisconnectedAt: lastDisconnectedAt ?? this.lastDisconnectedAt,
    );
  }

  @override
  List<Object?> get props => [
        status,
        error,
        retryCount,
        lastConnectedAt,
        lastDisconnectedAt,
      ];
}
