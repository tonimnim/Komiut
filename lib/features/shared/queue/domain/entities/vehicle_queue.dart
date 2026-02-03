/// Vehicle queue entity.
///
/// Represents the queue of vehicles for a specific route.
/// Contains the list of vehicles currently waiting at a stage/terminal.
library;

import 'queued_vehicle.dart';

/// Represents a queue of vehicles for a route.
///
/// Contains information about all vehicles currently in queue
/// at a stage/terminal for a specific route.
class VehicleQueue {
  /// Creates a new VehicleQueue instance.
  const VehicleQueue({
    required this.routeId,
    required this.routeName,
    required this.vehicles,
    required this.lastUpdated,
    this.stageName,
    this.stageId,
    this.organizationId,
    this.organizationName,
  });

  /// Unique identifier of the route.
  final String routeId;

  /// Display name of the route.
  final String routeName;

  /// List of vehicles currently in the queue.
  final List<QueuedVehicle> vehicles;

  /// Timestamp when the queue was last updated.
  final DateTime lastUpdated;

  /// Name of the stage/terminal where the queue is.
  final String? stageName;

  /// Unique identifier of the stage.
  final String? stageId;

  /// Unique identifier of the organization (sacco) managing the queue.
  final String? organizationId;

  /// Name of the organization (sacco) managing the queue.
  final String? organizationName;

  /// Total number of vehicles in the queue.
  int get vehicleCount => vehicles.length;

  /// Whether the queue is empty.
  bool get isEmpty => vehicles.isEmpty;

  /// Whether the queue has vehicles.
  bool get isNotEmpty => vehicles.isNotEmpty;

  /// Gets the first vehicle in the queue (next to depart).
  QueuedVehicle? get firstVehicle =>
      vehicles.isNotEmpty ? vehicles.first : null;

  /// Gets the vehicle currently boarding passengers.
  QueuedVehicle? get boardingVehicle {
    try {
      return vehicles.firstWhere((v) => v.isBoarding);
    } catch (_) {
      return null;
    }
  }

  /// Gets all vehicles currently waiting.
  List<QueuedVehicle> get waitingVehicles {
    return vehicles
        .where((v) => v.currentStatus == QueuedVehicleStatus.waiting)
        .toList();
  }

  /// Gets all vehicles with available seats.
  List<QueuedVehicle> get vehiclesWithAvailableSeats {
    return vehicles.where((v) => v.hasAvailableSeats).toList();
  }

  /// Total available seats across all vehicles in queue.
  int get totalAvailableSeats {
    return vehicles.fold(0, (sum, vehicle) => sum + vehicle.availableSeats);
  }

  /// Total seats (capacity) across all vehicles in queue.
  int get totalSeats {
    return vehicles.fold(0, (sum, vehicle) => sum + vehicle.totalSeats);
  }

  /// Formatted last updated time.
  String get formattedLastUpdated {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
  }

  /// Gets the estimated wait time based on queue position.
  ///
  /// [position] - The position in queue to calculate wait time for.
  /// Returns estimated minutes to wait based on average departure interval.
  int estimatedWaitMinutes({int position = 1, int avgDepartureMinutes = 15}) {
    if (position <= 1) return 0;
    return (position - 1) * avgDepartureMinutes;
  }

  /// Creates a copy of this queue with modified fields.
  VehicleQueue copyWith({
    String? routeId,
    String? routeName,
    List<QueuedVehicle>? vehicles,
    DateTime? lastUpdated,
    String? stageName,
    String? stageId,
    String? organizationId,
    String? organizationName,
  }) {
    return VehicleQueue(
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      vehicles: vehicles ?? this.vehicles,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      stageName: stageName ?? this.stageName,
      stageId: stageId ?? this.stageId,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
    );
  }

  /// Creates an empty queue for a route.
  factory VehicleQueue.empty({
    required String routeId,
    required String routeName,
    String? stageName,
    String? stageId,
  }) {
    return VehicleQueue(
      routeId: routeId,
      routeName: routeName,
      vehicles: const [],
      lastUpdated: DateTime.now(),
      stageName: stageName,
      stageId: stageId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleQueue &&
        other.routeId == routeId &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode => routeId.hashCode ^ lastUpdated.hashCode;

  @override
  String toString() {
    return 'VehicleQueue(routeId: $routeId, '
        'routeName: $routeName, '
        'vehicleCount: $vehicleCount, '
        'lastUpdated: $lastUpdated)';
  }
}
