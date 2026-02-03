/// Queued vehicle entity.
///
/// Represents a single vehicle in the queue for a route.
/// Contains vehicle details, queue position, and driver information.
///
/// Note: This entity is designed for the REST API responses while
/// [QueueVehicle] in queue_vehicle.dart is used for WebSocket real-time updates.
/// Both can be converted between each other using the provided conversion methods.
library;

import 'queue_vehicle.dart';

/// Status of a vehicle in the queue.
enum QueuedVehicleStatus {
  /// Vehicle is waiting in queue, not yet boarding passengers.
  waiting,

  /// Vehicle is currently boarding passengers.
  boarding,

  /// Vehicle is about to depart or has departed.
  departing,
}

/// Extension methods for [QueuedVehicleStatus].
extension QueuedVehicleStatusExtension on QueuedVehicleStatus {
  /// Converts enum to display string.
  String get displayName {
    switch (this) {
      case QueuedVehicleStatus.waiting:
        return 'Waiting';
      case QueuedVehicleStatus.boarding:
        return 'Boarding';
      case QueuedVehicleStatus.departing:
        return 'Departing';
    }
  }

  /// Converts enum to JSON string.
  String get toJson {
    switch (this) {
      case QueuedVehicleStatus.waiting:
        return 'waiting';
      case QueuedVehicleStatus.boarding:
        return 'boarding';
      case QueuedVehicleStatus.departing:
        return 'departing';
    }
  }

  /// Creates status from JSON string.
  static QueuedVehicleStatus fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'waiting':
        return QueuedVehicleStatus.waiting;
      case 'boarding':
        return QueuedVehicleStatus.boarding;
      case 'departing':
        return QueuedVehicleStatus.departing;
      default:
        return QueuedVehicleStatus.waiting;
    }
  }
}

/// Represents a vehicle in the queue.
///
/// Contains information about the vehicle's position in queue,
/// seat availability, estimated departure time, and driver details.
class QueuedVehicle {
  /// Creates a new QueuedVehicle instance.
  const QueuedVehicle({
    required this.vehicleId,
    required this.registrationNumber,
    required this.position,
    required this.availableSeats,
    required this.totalSeats,
    this.estimatedDepartureTime,
    required this.currentStatus,
    this.driverName,
    this.driverPhone,
    this.vehicleType,
    this.organizationName,
  });

  /// Unique identifier of the vehicle.
  final String vehicleId;

  /// Vehicle registration/license plate number.
  final String registrationNumber;

  /// Position in the queue (1 = first, 2 = second, etc.).
  final int position;

  /// Number of seats currently available.
  final int availableSeats;

  /// Total seating capacity of the vehicle.
  final int totalSeats;

  /// Estimated time when the vehicle will depart.
  final DateTime? estimatedDepartureTime;

  /// Current status of the vehicle in the queue.
  final QueuedVehicleStatus currentStatus;

  /// Name of the driver (optional).
  final String? driverName;

  /// Driver's phone number (optional).
  final String? driverPhone;

  /// Type of vehicle (e.g., matatu, bus, minibus).
  final String? vehicleType;

  /// Name of the sacco/organization operating this vehicle.
  final String? organizationName;

  /// Number of occupied seats.
  int get occupiedSeats => totalSeats - availableSeats;

  /// Whether the vehicle is full.
  bool get isFull => availableSeats <= 0;

  /// Whether the vehicle has seats available.
  bool get hasAvailableSeats => availableSeats > 0;

  /// Seat availability as a percentage (0.0 to 1.0).
  double get seatOccupancyRate =>
      totalSeats > 0 ? occupiedSeats / totalSeats : 0.0;

  /// Formatted position display (e.g., "1st", "2nd", "3rd").
  String get formattedPosition {
    if (position == 1) return '1st';
    if (position == 2) return '2nd';
    if (position == 3) return '3rd';
    return '${position}th';
  }

  /// Formatted seats display (e.g., "5/14 seats available").
  String get formattedSeats => '$availableSeats/$totalSeats seats available';

  /// Whether the vehicle is currently boarding passengers.
  bool get isBoarding => currentStatus == QueuedVehicleStatus.boarding;

  /// Whether the vehicle is about to depart.
  bool get isDeparting => currentStatus == QueuedVehicleStatus.departing;

  /// Creates a copy of this vehicle with modified fields.
  QueuedVehicle copyWith({
    String? vehicleId,
    String? registrationNumber,
    int? position,
    int? availableSeats,
    int? totalSeats,
    DateTime? estimatedDepartureTime,
    QueuedVehicleStatus? currentStatus,
    String? driverName,
    String? driverPhone,
    String? vehicleType,
    String? organizationName,
  }) {
    return QueuedVehicle(
      vehicleId: vehicleId ?? this.vehicleId,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      position: position ?? this.position,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      estimatedDepartureTime:
          estimatedDepartureTime ?? this.estimatedDepartureTime,
      currentStatus: currentStatus ?? this.currentStatus,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      vehicleType: vehicleType ?? this.vehicleType,
      organizationName: organizationName ?? this.organizationName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QueuedVehicle && other.vehicleId == vehicleId;
  }

  @override
  int get hashCode => vehicleId.hashCode;

  @override
  String toString() {
    return 'QueuedVehicle(vehicleId: $vehicleId, '
        'registrationNumber: $registrationNumber, '
        'position: $position, '
        'availableSeats: $availableSeats, '
        'totalSeats: $totalSeats, '
        'currentStatus: $currentStatus)';
  }

  /// Converts this entity to a [QueueVehicle] for WebSocket compatibility.
  ///
  /// Note: Some fields like [id], [routeId], [joinedAt], [make], [model], [color]
  /// will be empty or null as they are not available in this entity.
  QueueVehicle toQueueVehicle({String? routeId}) {
    return QueueVehicle(
      id: vehicleId,
      vehicleId: vehicleId,
      registrationNumber: registrationNumber,
      routeId: routeId ?? '',
      position: position,
      status: _convertStatus(currentStatus),
      totalSeats: totalSeats,
      availableSeats: availableSeats,
      driverName: driverName,
      estimatedDepartureTime: estimatedDepartureTime,
    );
  }

  /// Creates a [QueuedVehicle] from a [QueueVehicle].
  ///
  /// Useful when receiving WebSocket updates and need to update the REST model.
  factory QueuedVehicle.fromQueueVehicle(QueueVehicle qv) {
    return QueuedVehicle(
      vehicleId: qv.vehicleId,
      registrationNumber: qv.registrationNumber,
      position: qv.position,
      availableSeats: qv.availableSeats,
      totalSeats: qv.totalSeats,
      estimatedDepartureTime: qv.estimatedDepartureTime,
      currentStatus: _convertFromQueueVehicleStatus(qv.status),
      driverName: qv.driverName,
    );
  }

  /// Converts [QueuedVehicleStatus] to [QueueVehicleStatus].
  static QueueVehicleStatus _convertStatus(QueuedVehicleStatus status) {
    switch (status) {
      case QueuedVehicleStatus.waiting:
        return QueueVehicleStatus.waiting;
      case QueuedVehicleStatus.boarding:
        return QueueVehicleStatus.boarding;
      case QueuedVehicleStatus.departing:
        return QueueVehicleStatus.departing;
    }
  }

  /// Converts [QueueVehicleStatus] to [QueuedVehicleStatus].
  static QueuedVehicleStatus _convertFromQueueVehicleStatus(
      QueueVehicleStatus status) {
    switch (status) {
      case QueueVehicleStatus.waiting:
        return QueuedVehicleStatus.waiting;
      case QueueVehicleStatus.boarding:
        return QueuedVehicleStatus.boarding;
      case QueueVehicleStatus.departing:
      case QueueVehicleStatus.departed:
        return QueuedVehicleStatus.departing;
    }
  }
}
