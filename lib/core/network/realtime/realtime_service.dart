/// Abstract real-time communication service.
///
/// Defines the interface for real-time communication implementations
/// such as SignalR, WebSockets, or other real-time protocols.
library;

import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../errors/failures.dart';
import 'realtime_connection_state.dart';

/// Callback type for real-time message handlers.
typedef RealtimeMessageHandler<T> = void Function(T data);

/// Callback type for connection state changes.
typedef ConnectionStateHandler = void Function(RealtimeConnectionState state);

/// Abstract interface for real-time communication services.
///
/// Implementations should handle connection management, automatic reconnection,
/// and message routing to registered handlers.
abstract class RealtimeService {
  /// Stream of connection state changes.
  Stream<RealtimeConnectionState> get connectionStateStream;

  /// Current connection state.
  RealtimeConnectionState get currentState;

  /// Whether the service is currently connected.
  bool get isConnected;

  // ─────────────────────────────────────────────────────────────────────────
  // Connection Management
  // ─────────────────────────────────────────────────────────────────────────

  /// Establishes a connection to the real-time server.
  ///
  /// Returns [Right] with void on success, [Left] with [Failure] on error.
  Future<Either<Failure, void>> connect();

  /// Disconnects from the real-time server.
  ///
  /// Returns [Right] with void on success, [Left] with [Failure] on error.
  Future<Either<Failure, void>> disconnect();

  /// Reconnects to the server, typically after a connection loss.
  Future<Either<Failure, void>> reconnect();

  // ─────────────────────────────────────────────────────────────────────────
  // Queue Updates
  // ─────────────────────────────────────────────────────────────────────────

  /// Joins the queue updates channel for a specific route.
  ///
  /// After joining, the client will receive [onVehicleQueueUpdate] events
  /// for vehicles on this route.
  Future<Either<Failure, void>> joinQueueUpdates(String routeId);

  /// Leaves the queue updates channel for a specific route.
  ///
  /// Stops receiving updates for the specified route.
  Future<Either<Failure, void>> leaveQueueUpdates(String routeId);

  // ─────────────────────────────────────────────────────────────────────────
  // Event Handlers
  // ─────────────────────────────────────────────────────────────────────────

  /// Registers a handler for vehicle queue update events.
  ///
  /// Called when vehicles in a queue change position, depart, or arrive.
  void onVehicleQueueUpdate(RealtimeMessageHandler<VehicleQueueUpdate> handler);

  /// Registers a handler for vehicle position update events.
  ///
  /// Called when a tracked vehicle's GPS position changes.
  void onVehiclePositionUpdate(
      RealtimeMessageHandler<VehiclePositionUpdate> handler);

  /// Registers a handler for trip status change events.
  ///
  /// Called when a passenger's trip status changes (boarding, in-transit, arrived).
  void onTripStatusChange(RealtimeMessageHandler<TripStatusChange> handler);

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle Management
  // ─────────────────────────────────────────────────────────────────────────

  /// Called when the app is paused (backgrounded).
  ///
  /// Implementations may choose to disconnect or reduce activity.
  Future<void> onAppPaused();

  /// Called when the app is resumed (foregrounded).
  ///
  /// Implementations should reconnect if necessary.
  Future<void> onAppResumed();

  /// Disposes of resources used by the service.
  Future<void> dispose();
}

// ─────────────────────────────────────────────────────────────────────────────
// Data Transfer Objects
// ─────────────────────────────────────────────────────────────────────────────

/// Represents an update to a vehicle's position in the queue.
class VehicleQueueUpdate {
  /// Creates a vehicle queue update.
  const VehicleQueueUpdate({
    required this.routeId,
    required this.vehicleId,
    required this.vehicleRegistration,
    required this.queuePosition,
    required this.estimatedDepartureMinutes,
    required this.availableSeats,
    required this.totalSeats,
    this.saccoName,
    this.driverName,
  });

  /// Creates from JSON map.
  factory VehicleQueueUpdate.fromJson(Map<String, dynamic> json) {
    return VehicleQueueUpdate(
      routeId: json['routeId'] as String,
      vehicleId: json['vehicleId'] as String,
      vehicleRegistration: json['vehicleRegistration'] as String,
      queuePosition: json['queuePosition'] as int,
      estimatedDepartureMinutes: json['estimatedDepartureMinutes'] as int,
      availableSeats: json['availableSeats'] as int,
      totalSeats: json['totalSeats'] as int,
      saccoName: json['saccoName'] as String?,
      driverName: json['driverName'] as String?,
    );
  }

  /// The route this update is for.
  final String routeId;

  /// Unique identifier of the vehicle.
  final String vehicleId;

  /// Vehicle registration number (e.g., "KDG 123A").
  final String vehicleRegistration;

  /// Current position in the departure queue (1 = next to depart).
  final int queuePosition;

  /// Estimated minutes until departure.
  final int estimatedDepartureMinutes;

  /// Number of seats currently available.
  final int availableSeats;

  /// Total seat capacity of the vehicle.
  final int totalSeats;

  /// Name of the SACCO operating the vehicle.
  final String? saccoName;

  /// Name of the driver.
  final String? driverName;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'vehicleId': vehicleId,
      'vehicleRegistration': vehicleRegistration,
      'queuePosition': queuePosition,
      'estimatedDepartureMinutes': estimatedDepartureMinutes,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'saccoName': saccoName,
      'driverName': driverName,
    };
  }
}

/// Represents a GPS position update for a vehicle.
class VehiclePositionUpdate {
  /// Creates a vehicle position update.
  const VehiclePositionUpdate({
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.speed,
    required this.timestamp,
  });

  /// Creates from JSON map.
  factory VehiclePositionUpdate.fromJson(Map<String, dynamic> json) {
    return VehiclePositionUpdate(
      vehicleId: json['vehicleId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      heading: (json['heading'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Unique identifier of the vehicle.
  final String vehicleId;

  /// Latitude coordinate.
  final double latitude;

  /// Longitude coordinate.
  final double longitude;

  /// Direction of travel in degrees (0-360).
  final double heading;

  /// Current speed in km/h.
  final double speed;

  /// Timestamp of the position reading.
  final DateTime timestamp;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Represents a change in trip status.
class TripStatusChange {
  /// Creates a trip status change.
  const TripStatusChange({
    required this.tripId,
    required this.userId,
    required this.status,
    required this.timestamp,
    this.vehicleId,
    this.message,
  });

  /// Creates from JSON map.
  factory TripStatusChange.fromJson(Map<String, dynamic> json) {
    return TripStatusChange(
      tripId: json['tripId'] as String,
      userId: json['userId'] as String,
      status: TripStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TripStatus.unknown,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      vehicleId: json['vehicleId'] as String?,
      message: json['message'] as String?,
    );
  }

  /// Unique identifier of the trip.
  final String tripId;

  /// User ID of the passenger.
  final String userId;

  /// New status of the trip.
  final TripStatus status;

  /// Timestamp of the status change.
  final DateTime timestamp;

  /// Vehicle ID if applicable.
  final String? vehicleId;

  /// Optional message associated with the status change.
  final String? message;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'userId': userId,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'vehicleId': vehicleId,
      'message': message,
    };
  }
}

/// Possible statuses for a trip.
enum TripStatus {
  /// Unknown or unrecognized status.
  unknown,

  /// Trip has been booked but not yet started.
  booked,

  /// Passenger is boarding the vehicle.
  boarding,

  /// Trip is in progress.
  inTransit,

  /// Vehicle is approaching destination.
  approaching,

  /// Passenger has arrived at destination.
  arrived,

  /// Trip was completed successfully.
  completed,

  /// Trip was cancelled.
  cancelled,
}
