/// Queue state entity.
///
/// Represents the complete state of a vehicle queue for a route,
/// including connection status and optimistic update handling.
library;

import 'package:equatable/equatable.dart';

import 'queue_vehicle.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Connection State
// ─────────────────────────────────────────────────────────────────────────────

/// Connection state for real-time queue updates.
enum QueueConnectionState {
  /// Not connected to real-time updates.
  disconnected,

  /// Attempting to connect.
  connecting,

  /// Connected and receiving updates.
  connected,

  /// Connection lost, attempting to reconnect.
  reconnecting,

  /// Connection error occurred.
  error,
}

/// Extension methods for QueueConnectionState.
extension QueueConnectionStateX on QueueConnectionState {
  /// Display label for UI.
  String get label {
    switch (this) {
      case QueueConnectionState.disconnected:
        return 'Disconnected';
      case QueueConnectionState.connecting:
        return 'Connecting...';
      case QueueConnectionState.connected:
        return 'Live';
      case QueueConnectionState.reconnecting:
        return 'Reconnecting...';
      case QueueConnectionState.error:
        return 'Connection Error';
    }
  }

  /// Whether the connection is active.
  bool get isConnected => this == QueueConnectionState.connected;

  /// Whether a connection attempt is in progress.
  bool get isConnecting =>
      this == QueueConnectionState.connecting ||
      this == QueueConnectionState.reconnecting;

  /// Whether there's a connection issue.
  bool get hasIssue =>
      this == QueueConnectionState.error ||
      this == QueueConnectionState.disconnected;
}

// ─────────────────────────────────────────────────────────────────────────────
// Queue State
// ─────────────────────────────────────────────────────────────────────────────

/// Complete state of a vehicle queue for a route.
///
/// Contains the list of vehicles, connection status, and any pending
/// optimistic updates that need to be confirmed or rolled back.
class QueueState extends Equatable {
  /// Creates a new QueueState.
  const QueueState({
    required this.routeId,
    this.vehicles = const [],
    this.connectionState = QueueConnectionState.disconnected,
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.lastUpdated,
    this.selectedVehicleId,
    this.pendingSelection,
  });

  /// The route ID this queue belongs to.
  final String routeId;

  /// List of vehicles in the queue, sorted by position.
  final List<QueueVehicle> vehicles;

  /// Current connection state for real-time updates.
  final QueueConnectionState connectionState;

  /// Whether the initial load is in progress.
  final bool isLoading;

  /// Whether a sync operation is in progress (refresh/reconnect).
  final bool isSyncing;

  /// Current error message, if any.
  final String? error;

  /// When the queue was last updated.
  final DateTime? lastUpdated;

  /// ID of the currently selected vehicle.
  final String? selectedVehicleId;

  /// Pending vehicle selection (optimistic UI).
  final PendingVehicleSelection? pendingSelection;

  // ─────────────────────────────────────────────────────────────────────────
  // Factory Constructors
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates an initial loading state.
  factory QueueState.loading(String routeId) {
    return QueueState(
      routeId: routeId,
      isLoading: true,
      connectionState: QueueConnectionState.connecting,
    );
  }

  /// Creates an error state.
  factory QueueState.error(String routeId, String message) {
    return QueueState(
      routeId: routeId,
      error: message,
      connectionState: QueueConnectionState.error,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────

  /// Whether the queue is empty.
  bool get isEmpty => vehicles.isEmpty;

  /// Whether the queue has vehicles.
  bool get hasVehicles => vehicles.isNotEmpty;

  /// Total number of vehicles in the queue.
  int get vehicleCount => vehicles.length;

  /// The first vehicle in the queue (next to depart).
  QueueVehicle? get firstVehicle => vehicles.isNotEmpty ? vehicles.first : null;

  /// Vehicles that are currently boarding passengers.
  List<QueueVehicle> get boardingVehicles =>
      vehicles.where((v) => v.status == QueueVehicleStatus.boarding).toList();

  /// Vehicles that have available seats.
  List<QueueVehicle> get availableVehicles =>
      vehicles.where((v) => v.canBoard).toList();

  /// Total available seats across all vehicles.
  int get totalAvailableSeats =>
      vehicles.fold(0, (sum, v) => sum + v.availableSeats);

  /// Whether the connection is live.
  bool get isLive => connectionState.isConnected;

  /// Whether there's an error.
  bool get hasError => error != null;

  /// Whether an optimistic update is pending.
  bool get hasPendingUpdate => pendingSelection != null;

  /// The currently selected vehicle.
  QueueVehicle? get selectedVehicle {
    if (selectedVehicleId == null) return null;
    return vehicles.cast<QueueVehicle?>().firstWhere(
          (v) => v?.vehicleId == selectedVehicleId,
          orElse: () => null,
        );
  }

  /// Find a vehicle by ID.
  QueueVehicle? getVehicleById(String vehicleId) {
    return vehicles.cast<QueueVehicle?>().firstWhere(
          (v) => v?.vehicleId == vehicleId,
          orElse: () => null,
        );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Copy With
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates a copy with modified fields.
  QueueState copyWith({
    String? routeId,
    List<QueueVehicle>? vehicles,
    QueueConnectionState? connectionState,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    bool clearError = false,
    DateTime? lastUpdated,
    String? selectedVehicleId,
    bool clearSelectedVehicle = false,
    PendingVehicleSelection? pendingSelection,
    bool clearPendingSelection = false,
  }) {
    return QueueState(
      routeId: routeId ?? this.routeId,
      vehicles: vehicles ?? this.vehicles,
      connectionState: connectionState ?? this.connectionState,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
      selectedVehicleId: clearSelectedVehicle
          ? null
          : (selectedVehicleId ?? this.selectedVehicleId),
      pendingSelection: clearPendingSelection
          ? null
          : (pendingSelection ?? this.pendingSelection),
    );
  }

  @override
  List<Object?> get props => [
        routeId,
        vehicles,
        connectionState,
        isLoading,
        isSyncing,
        error,
        lastUpdated,
        selectedVehicleId,
        pendingSelection,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Pending Vehicle Selection
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a pending vehicle selection for optimistic UI.
///
/// Used to show immediate feedback when a user selects a vehicle,
/// before the server confirms the selection.
class PendingVehicleSelection extends Equatable {
  /// Creates a new PendingVehicleSelection.
  const PendingVehicleSelection({
    required this.vehicleId,
    required this.seatsRequested,
    required this.timestamp,
    this.isConfirmed = false,
    this.hasFailed = false,
    this.failureReason,
  });

  /// The vehicle ID being selected.
  final String vehicleId;

  /// Number of seats requested.
  final int seatsRequested;

  /// When the selection was made.
  final DateTime timestamp;

  /// Whether the server has confirmed the selection.
  final bool isConfirmed;

  /// Whether the selection failed.
  final bool hasFailed;

  /// Reason for failure, if any.
  final String? failureReason;

  /// Whether the selection is still pending.
  bool get isPending => !isConfirmed && !hasFailed;

  /// Creates a confirmed version.
  PendingVehicleSelection confirmed() {
    return PendingVehicleSelection(
      vehicleId: vehicleId,
      seatsRequested: seatsRequested,
      timestamp: timestamp,
      isConfirmed: true,
    );
  }

  /// Creates a failed version.
  PendingVehicleSelection failed(String reason) {
    return PendingVehicleSelection(
      vehicleId: vehicleId,
      seatsRequested: seatsRequested,
      timestamp: timestamp,
      hasFailed: true,
      failureReason: reason,
    );
  }

  @override
  List<Object?> get props => [
        vehicleId,
        seatsRequested,
        timestamp,
        isConfirmed,
        hasFailed,
        failureReason,
      ];
}
