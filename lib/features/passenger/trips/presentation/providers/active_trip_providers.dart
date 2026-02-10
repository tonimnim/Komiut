/// Active trip providers.
///
/// Provides state management for active trip tracking using Riverpod.
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/domain/entities/route_stop.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/active_trip.dart';

/// Provider for the current user's active trip.
///
/// Returns null if no active trip exists.
/// Usage:
/// ```dart
/// final activeTrip = ref.watch(activeTripProvider);
/// ```
final activeTripProvider = FutureProvider.autoDispose<ActiveTrip?>((ref) async {
  final authState = ref.watch(authStateProvider);
  if (authState.user == null) return null;

  // TODO: Implement actual API call to fetch active trip
  // Should call the trips API endpoint to get the user's current active trip.
  return null;
});

/// Provider for a specific trip by ID.
///
/// Usage:
/// ```dart
/// final trip = ref.watch(activeTripByIdProvider('trip-123'));
/// ```
final activeTripByIdProvider =
    FutureProvider.autoDispose.family<ActiveTrip?, String>((ref, tripId) async {
  // TODO: Implement actual API call to fetch trip by ID
  // Should call ApiEndpoints.tripById(tripId) to get the specific trip.
  return null;
});

/// Stream provider for vehicle GPS location updates.
///
/// Provides real-time vehicle position updates.
/// Usage:
/// ```dart
/// final position = ref.watch(tripVehicleLocationProvider);
/// ```
final tripVehicleLocationProvider =
    StreamProvider.autoDispose<VehiclePosition>((ref) {
  // TODO: Implement actual WebSocket/real-time stream from API
  // Should connect to a real-time vehicle tracking service.
  return const Stream<VehiclePosition>.empty();
});

/// Provider for calculated trip progress percentage.
///
/// Returns a value between 0.0 and 1.0.
/// Usage:
/// ```dart
/// final progress = ref.watch(tripProgressProvider);
/// ```
final tripProgressProvider = Provider.autoDispose<double>((ref) {
  final tripAsync = ref.watch(activeTripProvider);
  return tripAsync.maybeWhen(
    data: (trip) => trip?.progressPercentage ?? 0.0,
    orElse: () => 0.0,
  );
});

/// Provider for estimated time of arrival.
///
/// Usage:
/// ```dart
/// final eta = ref.watch(tripETAProvider);
/// ```
final tripETAProvider = Provider.autoDispose<DateTime?>((ref) {
  final tripAsync = ref.watch(activeTripProvider);
  return tripAsync.maybeWhen(
    data: (trip) => trip?.estimatedArrival,
    orElse: () => null,
  );
});

/// Provider for formatted ETA string.
///
/// Usage:
/// ```dart
/// final etaString = ref.watch(tripETAStringProvider);
/// ```
final tripETAStringProvider = Provider.autoDispose<String>((ref) {
  final tripAsync = ref.watch(activeTripProvider);
  return tripAsync.maybeWhen(
    data: (trip) => trip?.formattedETA ?? '--',
    orElse: () => '--',
  );
});

/// Provider for the next stop on the route.
///
/// Usage:
/// ```dart
/// final nextStop = ref.watch(nextStopProvider);
/// ```
final nextStopProvider = Provider.autoDispose<RouteStop?>((ref) {
  final tripAsync = ref.watch(activeTripProvider);
  return tripAsync.maybeWhen(
    data: (trip) => trip?.nextStop,
    orElse: () => null,
  );
});

/// Provider for stops remaining count.
///
/// Usage:
/// ```dart
/// final stopsRemaining = ref.watch(stopsRemainingProvider);
/// ```
final stopsRemainingProvider = Provider.autoDispose<int>((ref) {
  final tripAsync = ref.watch(activeTripProvider);
  return tripAsync.maybeWhen(
    data: (trip) => trip?.stopsRemaining ?? 0,
    orElse: () => 0,
  );
});

/// Provider for trip status.
///
/// Usage:
/// ```dart
/// final status = ref.watch(tripStatusProvider);
/// ```
final tripStatusProvider = Provider.autoDispose<ActiveTripStatus?>((ref) {
  final tripAsync = ref.watch(activeTripProvider);
  return tripAsync.maybeWhen(
    data: (trip) => trip?.status,
    orElse: () => null,
  );
});

/// Controller for trip actions.
///
/// Provides methods to interact with the active trip.
class ActiveTripController extends StateNotifier<AsyncValue<ActiveTrip?>> {
  // ignore: unused_field - will be used for API integration
  ActiveTripController(Ref ref) : super(const AsyncValue.loading()) {
    _loadActiveTrip();
  }

  Timer? _locationUpdateTimer;

  /// Load the active trip.
  Future<void> _loadActiveTrip() async {
    state = const AsyncValue.loading();
    try {
      // TODO: Implement actual API call to fetch the active trip.
      // Should call the trips API and start location updates if trip is active.
      const ActiveTrip? trip = null;
      state = const AsyncValue.data(trip);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refresh the active trip data.
  Future<void> refresh() async {
    await _loadActiveTrip();
  }

  /// Start periodic location updates.
  void _startLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _updateVehicleLocation(),
    );
  }

  /// Update vehicle location from real-time source.
  void _updateVehicleLocation() {
    // TODO: Implement actual vehicle location updates from API/WebSocket.
    // Should receive real GPS coordinates from the vehicle tracking service.
  }

  /// Cancel/exit the current trip.
  Future<void> cancelTrip() async {
    final currentTrip = state.valueOrNull;
    if (currentTrip == null) return;

    try {
      // TODO: Call API to cancel trip
      state = AsyncValue.data(
        currentTrip.copyWith(status: ActiveTripStatus.cancelled),
      );
      _locationUpdateTimer?.cancel();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Report an issue with the trip.
  Future<void> reportIssue(String issue) async {
    // TODO: Implement issue reporting
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }
}

/// Provider for the active trip controller.
final activeTripControllerProvider = StateNotifierProvider.autoDispose<
    ActiveTripController, AsyncValue<ActiveTrip?>>(
  (ref) => ActiveTripController(ref),
);

