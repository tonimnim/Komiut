/// Queue update handler.
///
/// Handles incoming queue events and updates the vehicle list accordingly.
/// Responsible for merging real-time updates with cached data and
/// maintaining proper sort order.
library;

import '../../domain/entities/entities.dart';

/// Handles queue events and updates the vehicle list.
///
/// This class is responsible for:
/// - Processing incoming queue events
/// - Merging real-time updates with existing data
/// - Maintaining vehicles sorted by queue position
/// - Handling add/remove/update operations
class QueueUpdateHandler {
  /// Creates a new QueueUpdateHandler.
  const QueueUpdateHandler({
    required this.routeId,
  });

  /// The route ID this handler is for.
  final String routeId;

  /// Handle a queue event and return updated vehicle list.
  ///
  /// Takes the current list of vehicles and an event, returns the
  /// updated list with the event applied.
  List<QueueVehicle> handleEvent(
    List<QueueVehicle> vehicles,
    QueueEvent event,
  ) {
    switch (event.type) {
      case QueueEventType.vehicleJoinedQueue:
        return _handleVehicleJoined(
          vehicles,
          event as VehicleJoinedQueueEvent,
        );

      case QueueEventType.vehicleLeftQueue:
        return _handleVehicleLeft(
          vehicles,
          event as VehicleLeftQueueEvent,
        );

      case QueueEventType.vehiclePositionChanged:
        return _handlePositionChanged(
          vehicles,
          event as VehiclePositionChangedEvent,
        );

      case QueueEventType.vehicleSeatCountChanged:
        return _handleSeatCountChanged(
          vehicles,
          event as VehicleSeatCountChangedEvent,
        );

      case QueueEventType.vehicleStatusChanged:
        return _handleStatusChanged(
          vehicles,
          event as VehicleStatusChangedEvent,
        );

      case QueueEventType.queueSynced:
        return _handleQueueSynced(
          event as QueueSyncedEvent,
        );

      case QueueEventType.error:
        // Errors don't modify the vehicle list
        return vehicles;
    }
  }

  /// Sort vehicles by queue position.
  List<QueueVehicle> sortVehicles(List<QueueVehicle> vehicles) {
    final sorted = List<QueueVehicle>.from(vehicles);
    sorted.sort((a, b) => a.position.compareTo(b.position));
    return sorted;
  }

  /// Handle vehicle joined event.
  List<QueueVehicle> _handleVehicleJoined(
    List<QueueVehicle> vehicles,
    VehicleJoinedQueueEvent event,
  ) {
    // Check if vehicle already exists (prevent duplicates)
    final existingIndex = vehicles.indexWhere(
      (v) => v.vehicleId == event.vehicle.vehicleId,
    );

    List<QueueVehicle> updated;
    if (existingIndex >= 0) {
      // Update existing vehicle
      updated = List<QueueVehicle>.from(vehicles);
      updated[existingIndex] = event.vehicle;
    } else {
      // Add new vehicle
      updated = [...vehicles, event.vehicle];
    }

    return sortVehicles(updated);
  }

  /// Handle vehicle left event.
  List<QueueVehicle> _handleVehicleLeft(
    List<QueueVehicle> vehicles,
    VehicleLeftQueueEvent event,
  ) {
    final updated =
        vehicles.where((v) => v.vehicleId != event.vehicleId).toList();

    // Recalculate positions for remaining vehicles
    return _recalculatePositions(updated);
  }

  /// Handle position changed event.
  List<QueueVehicle> _handlePositionChanged(
    List<QueueVehicle> vehicles,
    VehiclePositionChangedEvent event,
  ) {
    final updated = vehicles.map((v) {
      if (v.vehicleId == event.vehicleId) {
        return v.copyWith(position: event.newPosition);
      }
      return v;
    }).toList();

    return sortVehicles(updated);
  }

  /// Handle seat count changed event.
  List<QueueVehicle> _handleSeatCountChanged(
    List<QueueVehicle> vehicles,
    VehicleSeatCountChangedEvent event,
  ) {
    return vehicles.map((v) {
      if (v.vehicleId == event.vehicleId) {
        return v.copyWith(availableSeats: event.newSeatCount);
      }
      return v;
    }).toList();
  }

  /// Handle status changed event.
  List<QueueVehicle> _handleStatusChanged(
    List<QueueVehicle> vehicles,
    VehicleStatusChangedEvent event,
  ) {
    // If vehicle departed, remove from queue
    if (event.newStatus == QueueVehicleStatus.departed) {
      final updated =
          vehicles.where((v) => v.vehicleId != event.vehicleId).toList();
      return _recalculatePositions(updated);
    }

    return vehicles.map((v) {
      if (v.vehicleId == event.vehicleId) {
        return v.copyWith(status: event.newStatus);
      }
      return v;
    }).toList();
  }

  /// Handle queue synced event (full refresh).
  List<QueueVehicle> _handleQueueSynced(
    QueueSyncedEvent event,
  ) {
    return sortVehicles(event.vehicles);
  }

  /// Recalculate positions after removal.
  List<QueueVehicle> _recalculatePositions(List<QueueVehicle> vehicles) {
    final sorted = sortVehicles(vehicles);
    final updated = <QueueVehicle>[];

    for (var i = 0; i < sorted.length; i++) {
      updated.add(sorted[i].copyWith(position: i + 1));
    }

    return updated;
  }

  /// Merge new vehicles with existing ones.
  ///
  /// Used when receiving a partial update that should be merged
  /// with existing data rather than replacing it.
  List<QueueVehicle> mergeVehicles(
    List<QueueVehicle> existing,
    List<QueueVehicle> incoming,
  ) {
    final merged = Map<String, QueueVehicle>.fromEntries(
      existing.map((v) => MapEntry(v.vehicleId, v)),
    );

    for (final vehicle in incoming) {
      merged[vehicle.vehicleId] = vehicle;
    }

    return sortVehicles(merged.values.toList());
  }

  /// Find a vehicle by ID in the list.
  QueueVehicle? findVehicle(List<QueueVehicle> vehicles, String vehicleId) {
    for (final vehicle in vehicles) {
      if (vehicle.vehicleId == vehicleId) {
        return vehicle;
      }
    }
    return null;
  }

  /// Get vehicles available for boarding.
  List<QueueVehicle> getAvailableVehicles(List<QueueVehicle> vehicles) {
    return vehicles.where((v) => v.canBoard).toList();
  }

  /// Get the next vehicle to depart.
  QueueVehicle? getNextToDepart(List<QueueVehicle> vehicles) {
    final sorted = sortVehicles(vehicles);
    if (sorted.isEmpty) return null;
    return sorted.first;
  }

  /// Calculate total available seats.
  int getTotalAvailableSeats(List<QueueVehicle> vehicles) {
    return vehicles.fold(0, (sum, v) => sum + v.availableSeats);
  }

  /// Get estimated wait time for a position.
  ///
  /// Calculates based on average departure interval and position.
  Duration getEstimatedWaitTime(
    List<QueueVehicle> vehicles,
    int position, {
    Duration averageDepartureInterval = const Duration(minutes: 10),
  }) {
    if (position <= 0) return Duration.zero;
    return averageDepartureInterval * (position - 1);
  }
}
