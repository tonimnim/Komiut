/// Queue event entities for real-time updates.
///
/// Defines the event types and data structures for real-time queue updates.
/// These events are received from the WebSocket connection and used to
/// update the queue state optimistically.
library;

import 'package:equatable/equatable.dart';

import 'queue_vehicle.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Queue Event Types
// ─────────────────────────────────────────────────────────────────────────────

/// Types of queue events that can be received from the server.
enum QueueEventType {
  /// A vehicle has joined the queue.
  vehicleJoinedQueue,

  /// A vehicle has left the queue.
  vehicleLeftQueue,

  /// A vehicle's position in the queue has changed.
  vehiclePositionChanged,

  /// A vehicle's available seat count has changed.
  vehicleSeatCountChanged,

  /// A vehicle's status has changed (boarding/waiting/departing).
  vehicleStatusChanged,

  /// The queue data has been fully synced (initial load or reconnect).
  queueSynced,

  /// An error occurred in the queue stream.
  error,
}

/// Extension methods for QueueEventType.
extension QueueEventTypeX on QueueEventType {
  /// Parse event type from server string.
  static QueueEventType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'vehicle_joined_queue':
      case 'vehiclejoinedqueue':
        return QueueEventType.vehicleJoinedQueue;
      case 'vehicle_left_queue':
      case 'vehicleleftqueue':
        return QueueEventType.vehicleLeftQueue;
      case 'vehicle_position_changed':
      case 'vehiclepositionchanged':
        return QueueEventType.vehiclePositionChanged;
      case 'vehicle_seat_count_changed':
      case 'vehicleseatcountchanged':
        return QueueEventType.vehicleSeatCountChanged;
      case 'vehicle_status_changed':
      case 'vehiclestatuschanged':
        return QueueEventType.vehicleStatusChanged;
      case 'queue_synced':
      case 'queuesynced':
        return QueueEventType.queueSynced;
      case 'error':
        return QueueEventType.error;
      default:
        return QueueEventType.error;
    }
  }

  /// Display label for UI.
  String get label {
    switch (this) {
      case QueueEventType.vehicleJoinedQueue:
        return 'Vehicle Joined';
      case QueueEventType.vehicleLeftQueue:
        return 'Vehicle Left';
      case QueueEventType.vehiclePositionChanged:
        return 'Position Changed';
      case QueueEventType.vehicleSeatCountChanged:
        return 'Seats Updated';
      case QueueEventType.vehicleStatusChanged:
        return 'Status Changed';
      case QueueEventType.queueSynced:
        return 'Queue Synced';
      case QueueEventType.error:
        return 'Error';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Queue Event Base Class
// ─────────────────────────────────────────────────────────────────────────────

/// Base class for queue events.
///
/// All queue events extend this class and contain the event type,
/// route ID, and optional timestamp.
abstract class QueueEvent extends Equatable {
  /// Creates a new QueueEvent.
  const QueueEvent({
    required this.type,
    required this.routeId,
    this.timestamp,
  });

  /// The type of the event.
  final QueueEventType type;

  /// The route ID this event belongs to.
  final String routeId;

  /// When the event occurred (server time).
  final DateTime? timestamp;

  @override
  List<Object?> get props => [type, routeId, timestamp];

  /// Factory constructor to parse events from JSON.
  factory QueueEvent.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'error';
    final type = QueueEventTypeX.fromString(typeStr);
    final routeId = json['routeId'] as String? ?? '';
    final timestamp = json['timestamp'] != null
        ? DateTime.tryParse(json['timestamp'] as String)
        : null;

    switch (type) {
      case QueueEventType.vehicleJoinedQueue:
        return VehicleJoinedQueueEvent(
          routeId: routeId,
          timestamp: timestamp,
          vehicle: QueueVehicle.fromJson(
            json['vehicle'] as Map<String, dynamic>? ?? {},
          ),
        );

      case QueueEventType.vehicleLeftQueue:
        return VehicleLeftQueueEvent(
          routeId: routeId,
          timestamp: timestamp,
          vehicleId: json['vehicleId'] as String? ?? '',
        );

      case QueueEventType.vehiclePositionChanged:
        return VehiclePositionChangedEvent(
          routeId: routeId,
          timestamp: timestamp,
          vehicleId: json['vehicleId'] as String? ?? '',
          oldPosition: json['oldPosition'] as int? ?? 0,
          newPosition: json['newPosition'] as int? ?? 0,
        );

      case QueueEventType.vehicleSeatCountChanged:
        return VehicleSeatCountChangedEvent(
          routeId: routeId,
          timestamp: timestamp,
          vehicleId: json['vehicleId'] as String? ?? '',
          oldSeatCount: json['oldSeatCount'] as int? ?? 0,
          newSeatCount: json['newSeatCount'] as int? ?? 0,
        );

      case QueueEventType.vehicleStatusChanged:
        return VehicleStatusChangedEvent(
          routeId: routeId,
          timestamp: timestamp,
          vehicleId: json['vehicleId'] as String? ?? '',
          oldStatus: QueueVehicleStatusX.fromString(
            json['oldStatus'] as String? ?? '',
          ),
          newStatus: QueueVehicleStatusX.fromString(
            json['newStatus'] as String? ?? '',
          ),
        );

      case QueueEventType.queueSynced:
        return QueueSyncedEvent(
          routeId: routeId,
          timestamp: timestamp,
          vehicles: (json['vehicles'] as List<dynamic>? ?? [])
              .map((v) => QueueVehicle.fromJson(v as Map<String, dynamic>))
              .toList(),
        );

      case QueueEventType.error:
        return QueueErrorEvent(
          routeId: routeId,
          timestamp: timestamp,
          message: json['message'] as String? ?? 'Unknown error',
          code: json['code'] as String?,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Concrete Event Classes
// ─────────────────────────────────────────────────────────────────────────────

/// Event when a vehicle joins the queue.
class VehicleJoinedQueueEvent extends QueueEvent {
  /// Creates a VehicleJoinedQueueEvent.
  const VehicleJoinedQueueEvent({
    required super.routeId,
    super.timestamp,
    required this.vehicle,
  }) : super(type: QueueEventType.vehicleJoinedQueue);

  /// The vehicle that joined.
  final QueueVehicle vehicle;

  @override
  List<Object?> get props => [...super.props, vehicle];
}

/// Event when a vehicle leaves the queue.
class VehicleLeftQueueEvent extends QueueEvent {
  /// Creates a VehicleLeftQueueEvent.
  const VehicleLeftQueueEvent({
    required super.routeId,
    super.timestamp,
    required this.vehicleId,
  }) : super(type: QueueEventType.vehicleLeftQueue);

  /// The ID of the vehicle that left.
  final String vehicleId;

  @override
  List<Object?> get props => [...super.props, vehicleId];
}

/// Event when a vehicle's position changes.
class VehiclePositionChangedEvent extends QueueEvent {
  /// Creates a VehiclePositionChangedEvent.
  const VehiclePositionChangedEvent({
    required super.routeId,
    super.timestamp,
    required this.vehicleId,
    required this.oldPosition,
    required this.newPosition,
  }) : super(type: QueueEventType.vehiclePositionChanged);

  /// The ID of the vehicle.
  final String vehicleId;

  /// Previous queue position.
  final int oldPosition;

  /// New queue position.
  final int newPosition;

  @override
  List<Object?> get props => [
        ...super.props,
        vehicleId,
        oldPosition,
        newPosition,
      ];
}

/// Event when a vehicle's seat count changes.
class VehicleSeatCountChangedEvent extends QueueEvent {
  /// Creates a VehicleSeatCountChangedEvent.
  const VehicleSeatCountChangedEvent({
    required super.routeId,
    super.timestamp,
    required this.vehicleId,
    required this.oldSeatCount,
    required this.newSeatCount,
  }) : super(type: QueueEventType.vehicleSeatCountChanged);

  /// The ID of the vehicle.
  final String vehicleId;

  /// Previous available seat count.
  final int oldSeatCount;

  /// New available seat count.
  final int newSeatCount;

  @override
  List<Object?> get props => [
        ...super.props,
        vehicleId,
        oldSeatCount,
        newSeatCount,
      ];
}

/// Event when a vehicle's status changes.
class VehicleStatusChangedEvent extends QueueEvent {
  /// Creates a VehicleStatusChangedEvent.
  const VehicleStatusChangedEvent({
    required super.routeId,
    super.timestamp,
    required this.vehicleId,
    required this.oldStatus,
    required this.newStatus,
  }) : super(type: QueueEventType.vehicleStatusChanged);

  /// The ID of the vehicle.
  final String vehicleId;

  /// Previous status.
  final QueueVehicleStatus oldStatus;

  /// New status.
  final QueueVehicleStatus newStatus;

  @override
  List<Object?> get props => [
        ...super.props,
        vehicleId,
        oldStatus,
        newStatus,
      ];
}

/// Event when queue data is fully synced.
class QueueSyncedEvent extends QueueEvent {
  /// Creates a QueueSyncedEvent.
  const QueueSyncedEvent({
    required super.routeId,
    super.timestamp,
    required this.vehicles,
  }) : super(type: QueueEventType.queueSynced);

  /// Full list of vehicles in the queue.
  final List<QueueVehicle> vehicles;

  @override
  List<Object?> get props => [...super.props, vehicles];
}

/// Event when an error occurs.
class QueueErrorEvent extends QueueEvent {
  /// Creates a QueueErrorEvent.
  const QueueErrorEvent({
    required super.routeId,
    super.timestamp,
    required this.message,
    this.code,
  }) : super(type: QueueEventType.error);

  /// Error message.
  final String message;

  /// Optional error code.
  final String? code;

  @override
  List<Object?> get props => [...super.props, message, code];
}
