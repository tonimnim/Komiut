/// Queue providers for managing vehicle queue state.
///
/// Provides queue data with API-first approach.
/// Supports fetching queues by route, vehicle details, and manual refresh.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/queue_remote_datasource.dart';
import '../../domain/entities/queued_vehicle.dart';
import '../../domain/entities/vehicle_queue.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Queue Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for fetching the queue for a specific route.
///
/// [routeId] - The unique identifier of the route.
/// Returns [VehicleQueue] entity or throws on error.
final queueForRouteProvider =
    FutureProvider.family<VehicleQueue, String>((ref, routeId) async {
  // Watch the refresh provider to allow manual refresh
  ref.watch(queueRefreshProvider);

  final remoteDataSource = ref.watch(queueRemoteDataSourceProvider);
  final result = await remoteDataSource.getQueueForRoute(routeId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (queue) => queue,
  );
});

/// Provider for fetching detailed vehicle information.
///
/// [vehicleId] - The unique identifier of the vehicle.
/// Returns [QueuedVehicle] entity or throws on error.
final vehicleDetailsProvider =
    FutureProvider.family<QueuedVehicle, String>((ref, vehicleId) async {
  final remoteDataSource = ref.watch(queueRemoteDataSourceProvider);
  final result = await remoteDataSource.getVehicleDetails(vehicleId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (vehicle) => vehicle,
  );
});

/// Provider for fetching all queues.
///
/// Returns a list of all [VehicleQueue] entities.
final allQueuesProvider = FutureProvider<List<VehicleQueue>>((ref) async {
  // Watch the refresh provider to allow manual refresh
  ref.watch(queueRefreshProvider);

  final remoteDataSource = ref.watch(queueRemoteDataSourceProvider);
  final result = await remoteDataSource.getAllQueues();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (queues) => queues,
  );
});

/// Provider for fetching queue by stage/terminal.
///
/// [stageId] - The unique identifier of the stage/terminal.
/// Returns [VehicleQueue] entity or throws on error.
final queueForStageProvider =
    FutureProvider.family<VehicleQueue, String>((ref, stageId) async {
  // Watch the refresh provider to allow manual refresh
  ref.watch(queueRefreshProvider);

  final remoteDataSource = ref.watch(queueRemoteDataSourceProvider);
  final result = await remoteDataSource.getQueueForStage(stageId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (queue) => queue,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Selection Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the currently selected vehicle in the queue.
///
/// Used when user taps on a vehicle to view details or book.
final selectedQueueVehicleProvider =
    StateProvider<QueuedVehicle?>((ref) => null);

/// Provider for the currently selected queue.
///
/// Used when viewing queue details.
final selectedQueueProvider = StateProvider<VehicleQueue?>((ref) => null);

// ─────────────────────────────────────────────────────────────────────────────
// Refresh Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for triggering queue refresh.
///
/// Increment this value to invalidate and refresh all queue providers.
/// Usage: ref.read(queueRefreshProvider.notifier).state++
final queueRefreshProvider = StateProvider<int>((ref) => 0);

/// Function provider for refreshing queue data.
///
/// Returns a function that can be called to refresh all queue-related providers.
final refreshQueueProvider = Provider<void Function()>((ref) {
  return () {
    // Increment the refresh counter to trigger provider invalidation
    ref.read(queueRefreshProvider.notifier).state++;
  };
});

/// Function provider for refreshing a specific route's queue.
///
/// Returns a function that can be called to refresh a specific route's queue.
final refreshRouteQueueProvider =
    Provider.family<void Function(), String>((ref, routeId) {
  return () {
    ref.invalidate(queueForRouteProvider(routeId));
  };
});

// ─────────────────────────────────────────────────────────────────────────────
// Derived/Computed Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the first vehicle in the queue (next to depart) for a route.
///
/// [routeId] - The unique identifier of the route.
/// Returns the first [QueuedVehicle] or null if queue is empty.
final nextVehicleForRouteProvider =
    Provider.family<AsyncValue<QueuedVehicle?>, String>((ref, routeId) {
  final queueAsync = ref.watch(queueForRouteProvider(routeId));

  return queueAsync.whenData((queue) => queue.firstVehicle);
});

/// Provider for the currently boarding vehicle for a route.
///
/// [routeId] - The unique identifier of the route.
/// Returns the boarding [QueuedVehicle] or null if none is boarding.
final boardingVehicleForRouteProvider =
    Provider.family<AsyncValue<QueuedVehicle?>, String>((ref, routeId) {
  final queueAsync = ref.watch(queueForRouteProvider(routeId));

  return queueAsync.whenData((queue) => queue.boardingVehicle);
});

/// Provider for vehicles with available seats for a route.
///
/// [routeId] - The unique identifier of the route.
/// Returns list of [QueuedVehicle] with available seats.
final vehiclesWithSeatsProvider =
    Provider.family<AsyncValue<List<QueuedVehicle>>, String>((ref, routeId) {
  final queueAsync = ref.watch(queueForRouteProvider(routeId));

  return queueAsync.whenData((queue) => queue.vehiclesWithAvailableSeats);
});

/// Provider for total available seats across a route's queue.
///
/// [routeId] - The unique identifier of the route.
/// Returns total number of available seats.
final totalAvailableSeatsProvider =
    Provider.family<AsyncValue<int>, String>((ref, routeId) {
  final queueAsync = ref.watch(queueForRouteProvider(routeId));

  return queueAsync.whenData((queue) => queue.totalAvailableSeats);
});

/// Provider for queue vehicle count for a route.
///
/// [routeId] - The unique identifier of the route.
/// Returns the number of vehicles in the queue.
final queueVehicleCountProvider =
    Provider.family<AsyncValue<int>, String>((ref, routeId) {
  final queueAsync = ref.watch(queueForRouteProvider(routeId));

  return queueAsync.whenData((queue) => queue.vehicleCount);
});

// ─────────────────────────────────────────────────────────────────────────────
// Filter Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Filter options for queue display.
enum QueueVehicleFilter {
  /// Show all vehicles in queue.
  all,

  /// Show only vehicles with available seats.
  availableSeats,

  /// Show only vehicles currently boarding.
  boarding,

  /// Show only waiting vehicles.
  waiting,
}

/// Provider for the current queue filter.
final queueFilterProvider = StateProvider<QueueVehicleFilter>((ref) {
  return QueueVehicleFilter.all;
});

/// Provider for filtered vehicles in a route's queue.
///
/// Applies the selected filter to the queue's vehicles.
final filteredQueueVehiclesProvider =
    Provider.family<AsyncValue<List<QueuedVehicle>>, String>((ref, routeId) {
  final queueAsync = ref.watch(queueForRouteProvider(routeId));
  final filter = ref.watch(queueFilterProvider);

  return queueAsync.whenData((queue) {
    switch (filter) {
      case QueueVehicleFilter.all:
        return queue.vehicles;
      case QueueVehicleFilter.availableSeats:
        return queue.vehiclesWithAvailableSeats;
      case QueueVehicleFilter.boarding:
        return queue.vehicles
            .where((v) => v.currentStatus == QueuedVehicleStatus.boarding)
            .toList();
      case QueueVehicleFilter.waiting:
        return queue.waitingVehicles;
    }
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Auto-Refresh Support
// ─────────────────────────────────────────────────────────────────────────────

/// Provider that indicates if auto-refresh is enabled.
final queueAutoRefreshEnabledProvider = StateProvider<bool>((ref) => false);

/// Provider for auto-refresh interval in seconds.
final queueAutoRefreshIntervalProvider = StateProvider<int>((ref) => 30);
