/// Trip entity.
///
/// Represents a scheduled or ongoing trip.
library;

import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// Trip entity representing a vehicle trip.
class Trip extends Equatable {
  /// Creates a new Trip instance.
  const Trip({
    required this.id,
    required this.vehicleId,
    required this.routeId,
    this.driverId,
    this.toutId,
    this.startTime,
    this.endTime,
    required this.status,
    this.vehicleRegistration,
    this.routeName,
    this.driverName,
    this.toutName,
    this.availableSeats,
    this.totalSeats,
    this.currentStopId,
    this.nextStopId,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier.
  final String id;

  /// ID of the vehicle.
  final String vehicleId;

  /// ID of the route.
  final String routeId;

  /// ID of the driver (if assigned).
  final String? driverId;

  /// ID of the tout (if assigned).
  final String? toutId;

  /// When the trip started/will start.
  final DateTime? startTime;

  /// When the trip ended.
  final DateTime? endTime;

  /// Trip status.
  final TripStatus status;

  /// Vehicle registration number (for display).
  final String? vehicleRegistration;

  /// Route name (for display).
  final String? routeName;

  /// Driver name (for display).
  final String? driverName;

  /// Tout name (for display).
  final String? toutName;

  /// Number of available seats.
  final int? availableSeats;

  /// Total number of seats.
  final int? totalSeats;

  /// ID of current stop (if in progress).
  final String? currentStopId;

  /// ID of next stop (if in progress).
  final String? nextStopId;

  /// When the trip was created.
  final DateTime? createdAt;

  /// When the trip was last updated.
  final DateTime? updatedAt;

  /// Whether the trip is scheduled.
  bool get isScheduled => status == TripStatus.scheduled;

  /// Whether the trip is in progress.
  bool get isInProgress => status == TripStatus.inProgress;

  /// Whether the trip is completed.
  bool get isCompleted => status == TripStatus.completed;

  /// Whether the trip is cancelled.
  bool get isCancelled => status == TripStatus.cancelled;

  /// Whether the trip has a driver.
  bool get hasDriver => driverId != null;

  /// Whether the trip has a tout.
  bool get hasTout => toutId != null;

  /// Whether seats information is available.
  bool get hasSeatsInfo => availableSeats != null && totalSeats != null;

  /// Number of occupied seats.
  int? get occupiedSeats {
    if (!hasSeatsInfo) return null;
    return totalSeats! - availableSeats!;
  }

  /// Seat occupancy percentage.
  double? get occupancyPercentage {
    if (!hasSeatsInfo || totalSeats == 0) return null;
    return (occupiedSeats! / totalSeats!) * 100;
  }

  /// Whether the trip has available seats.
  bool get hasAvailableSeats => availableSeats != null && availableSeats! > 0;

  /// Creates a copy with modified fields.
  Trip copyWith({
    String? id,
    String? vehicleId,
    String? routeId,
    String? driverId,
    String? toutId,
    DateTime? startTime,
    DateTime? endTime,
    TripStatus? status,
    String? vehicleRegistration,
    String? routeName,
    String? driverName,
    String? toutName,
    int? availableSeats,
    int? totalSeats,
    String? currentStopId,
    String? nextStopId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      routeId: routeId ?? this.routeId,
      driverId: driverId ?? this.driverId,
      toutId: toutId ?? this.toutId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      routeName: routeName ?? this.routeName,
      driverName: driverName ?? this.driverName,
      toutName: toutName ?? this.toutName,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      currentStopId: currentStopId ?? this.currentStopId,
      nextStopId: nextStopId ?? this.nextStopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        routeId,
        driverId,
        toutId,
        startTime,
        endTime,
        status,
        vehicleRegistration,
        routeName,
        driverName,
        toutName,
        availableSeats,
        totalSeats,
        currentStopId,
        nextStopId,
        createdAt,
        updatedAt,
      ];
}
