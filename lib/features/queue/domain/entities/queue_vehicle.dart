/// Queue vehicle entity.
///
/// Represents a vehicle in the departure queue with its current state.
library;

import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Queue Vehicle Status
// ─────────────────────────────────────────────────────────────────────────────

/// Status of a vehicle in the queue.
enum QueueVehicleStatus {
  /// Vehicle is waiting in queue, not yet boarding.
  waiting,

  /// Vehicle is actively boarding passengers.
  boarding,

  /// Vehicle is about to depart (full or time limit reached).
  departing,

  /// Vehicle has departed.
  departed,
}

/// Extension methods for QueueVehicleStatus.
extension QueueVehicleStatusX on QueueVehicleStatus {
  /// Parse status from string.
  static QueueVehicleStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'waiting':
        return QueueVehicleStatus.waiting;
      case 'boarding':
        return QueueVehicleStatus.boarding;
      case 'departing':
        return QueueVehicleStatus.departing;
      case 'departed':
        return QueueVehicleStatus.departed;
      default:
        return QueueVehicleStatus.waiting;
    }
  }

  /// Convert to API string value.
  String toApiValue() => name;

  /// Display label for UI.
  String get label {
    switch (this) {
      case QueueVehicleStatus.waiting:
        return 'Waiting';
      case QueueVehicleStatus.boarding:
        return 'Boarding';
      case QueueVehicleStatus.departing:
        return 'Departing';
      case QueueVehicleStatus.departed:
        return 'Departed';
    }
  }

  /// Whether passengers can board this vehicle.
  bool get canBoard =>
      this == QueueVehicleStatus.waiting || this == QueueVehicleStatus.boarding;

  /// Whether the vehicle is still in the active queue.
  bool get isInQueue =>
      this != QueueVehicleStatus.departed;
}

// ─────────────────────────────────────────────────────────────────────────────
// Queue Vehicle Entity
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a vehicle in the departure queue.
///
/// Contains all information needed to display a vehicle in the queue,
/// including its position, seat availability, and current status.
class QueueVehicle extends Equatable {
  /// Creates a new QueueVehicle instance.
  const QueueVehicle({
    required this.id,
    required this.vehicleId,
    required this.registrationNumber,
    required this.routeId,
    required this.position,
    required this.status,
    required this.totalSeats,
    required this.availableSeats,
    this.driverName,
    this.estimatedDepartureTime,
    this.joinedAt,
    this.make,
    this.model,
    this.color,
  });

  /// Unique queue entry ID.
  final String id;

  /// Vehicle ID reference.
  final String vehicleId;

  /// Vehicle registration/plate number.
  final String registrationNumber;

  /// Route ID the vehicle is queued for.
  final String routeId;

  /// Position in the queue (1-indexed).
  final int position;

  /// Current status of the vehicle in queue.
  final QueueVehicleStatus status;

  /// Total passenger capacity.
  final int totalSeats;

  /// Currently available seats.
  final int availableSeats;

  /// Name of the driver (if available).
  final String? driverName;

  /// Estimated time of departure.
  final DateTime? estimatedDepartureTime;

  /// When the vehicle joined the queue.
  final DateTime? joinedAt;

  /// Vehicle make (e.g., Toyota).
  final String? make;

  /// Vehicle model (e.g., Hiace).
  final String? model;

  /// Vehicle color.
  final String? color;

  // ─────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────

  /// Number of occupied seats.
  int get occupiedSeats => totalSeats - availableSeats;

  /// Whether the vehicle is full.
  bool get isFull => availableSeats <= 0;

  /// Whether the vehicle has seats available.
  bool get hasSeats => availableSeats > 0;

  /// Seat occupancy percentage (0.0 to 1.0).
  double get occupancyPercentage {
    if (totalSeats <= 0) return 0.0;
    return occupiedSeats / totalSeats;
  }

  /// Display name combining registration and make/model.
  String get displayName {
    if (make != null && model != null) {
      return '$registrationNumber - $make $model';
    }
    return registrationNumber;
  }

  /// Short display name (just registration).
  String get shortName => registrationNumber;

  /// Formatted seat count display.
  String get seatDisplay => '$availableSeats/$totalSeats seats';

  /// Formatted position display.
  String get positionDisplay => '#$position';

  /// Whether passengers can currently board.
  bool get canBoard => status.canBoard && hasSeats;

  /// Whether this is the first vehicle in queue.
  bool get isFirst => position == 1;

  /// Formatted estimated departure time.
  String? get formattedDepartureTime {
    if (estimatedDepartureTime == null) return null;
    final now = DateTime.now();
    final diff = estimatedDepartureTime!.difference(now);

    if (diff.isNegative) return 'Departing soon';
    if (diff.inMinutes < 1) return 'Less than 1 min';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // JSON Serialization
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates a QueueVehicle from JSON.
  factory QueueVehicle.fromJson(Map<String, dynamic> json) {
    return QueueVehicle(
      id: json['id'] as String? ?? '',
      vehicleId: json['vehicleId'] as String? ?? '',
      registrationNumber: json['registrationNumber'] as String? ?? '',
      routeId: json['routeId'] as String? ?? '',
      position: json['position'] as int? ?? 0,
      status: QueueVehicleStatusX.fromString(
        json['status'] as String? ?? 'waiting',
      ),
      totalSeats: json['totalSeats'] as int? ?? 0,
      availableSeats: json['availableSeats'] as int? ?? 0,
      driverName: json['driverName'] as String?,
      estimatedDepartureTime: json['estimatedDepartureTime'] != null
          ? DateTime.tryParse(json['estimatedDepartureTime'] as String)
          : null,
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'] as String)
          : null,
      make: json['make'] as String?,
      model: json['model'] as String?,
      color: json['color'] as String?,
    );
  }

  /// Converts this QueueVehicle to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'registrationNumber': registrationNumber,
      'routeId': routeId,
      'position': position,
      'status': status.toApiValue(),
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      if (driverName != null) 'driverName': driverName,
      if (estimatedDepartureTime != null)
        'estimatedDepartureTime': estimatedDepartureTime!.toIso8601String(),
      if (joinedAt != null) 'joinedAt': joinedAt!.toIso8601String(),
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (color != null) 'color': color,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Copy With
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates a copy with modified fields.
  QueueVehicle copyWith({
    String? id,
    String? vehicleId,
    String? registrationNumber,
    String? routeId,
    int? position,
    QueueVehicleStatus? status,
    int? totalSeats,
    int? availableSeats,
    String? driverName,
    DateTime? estimatedDepartureTime,
    DateTime? joinedAt,
    String? make,
    String? model,
    String? color,
  }) {
    return QueueVehicle(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      routeId: routeId ?? this.routeId,
      position: position ?? this.position,
      status: status ?? this.status,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      driverName: driverName ?? this.driverName,
      estimatedDepartureTime:
          estimatedDepartureTime ?? this.estimatedDepartureTime,
      joinedAt: joinedAt ?? this.joinedAt,
      make: make ?? this.make,
      model: model ?? this.model,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        registrationNumber,
        routeId,
        position,
        status,
        totalSeats,
        availableSeats,
        driverName,
        estimatedDepartureTime,
        joinedAt,
        make,
        model,
        color,
      ];
}
