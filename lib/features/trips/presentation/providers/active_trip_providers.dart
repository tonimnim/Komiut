/// Active trip providers.
///
/// Provides state management for active trip tracking using Riverpod.
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/route_stop.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
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

  // TODO: Replace with actual API call to fetch active trip
  // For now, return mock data for demonstration
  await Future.delayed(const Duration(milliseconds: 500));

  // Simulated active trip data
  return _getMockActiveTrip();
});

/// Provider for a specific trip by ID.
///
/// Usage:
/// ```dart
/// final trip = ref.watch(activeTripByIdProvider('trip-123'));
/// ```
final activeTripByIdProvider =
    FutureProvider.autoDispose.family<ActiveTrip?, String>((ref, tripId) async {
  // TODO: Replace with actual API call
  await Future.delayed(const Duration(milliseconds: 500));

  return _getMockActiveTrip(tripId: tripId);
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
  // TODO: Replace with actual WebSocket/real-time stream from API
  return _mockVehicleLocationStream();
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
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      final trip = _getMockActiveTrip();
      state = AsyncValue.data(trip);

      // Start location updates if trip is active
      if (trip != null && trip.isActive) {
        _startLocationUpdates();
      }
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

  /// Update vehicle location (simulated).
  void _updateVehicleLocation() {
    final currentTrip = state.valueOrNull;
    if (currentTrip == null) return;

    // TODO: Replace with actual API call for location
    // For now, simulate slight position changes
    final currentPos = currentTrip.currentVehiclePosition;
    if (currentPos != null) {
      final newPosition = VehiclePosition(
        latitude: currentPos.latitude + 0.0001,
        longitude: currentPos.longitude + 0.0001,
        heading: currentPos.heading,
        speed: 25.0 + (DateTime.now().second % 10),
        updatedAt: DateTime.now(),
      );

      state = AsyncValue.data(
        currentTrip.copyWith(currentVehiclePosition: newPosition),
      );
    }
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
final activeTripControllerProvider =
    StateNotifierProvider.autoDispose<ActiveTripController, AsyncValue<ActiveTrip?>>(
  (ref) => ActiveTripController(ref),
);

// ─────────────────────────────────────────────────────────────────────────────
// Mock Data Helpers (to be replaced with actual API integration)
// ─────────────────────────────────────────────────────────────────────────────

/// Generate mock active trip data.
ActiveTrip? _getMockActiveTrip({String? tripId}) {
  final stops = [
    const RouteStop(
      id: 'stop-1',
      routeId: 'route-1',
      name: 'CBD - Kenya Cinema',
      latitude: -1.2864,
      longitude: 36.8172,
      sequence: 0,
      estimatedTimeFromStart: 0,
    ),
    const RouteStop(
      id: 'stop-2',
      routeId: 'route-1',
      name: 'Globe Cinema',
      latitude: -1.2835,
      longitude: 36.8256,
      sequence: 1,
      estimatedTimeFromStart: 5,
    ),
    const RouteStop(
      id: 'stop-3',
      routeId: 'route-1',
      name: 'Ngara',
      latitude: -1.2750,
      longitude: 36.8300,
      sequence: 2,
      estimatedTimeFromStart: 10,
    ),
    const RouteStop(
      id: 'stop-4',
      routeId: 'route-1',
      name: 'Pangani',
      latitude: -1.2680,
      longitude: 36.8400,
      sequence: 3,
      estimatedTimeFromStart: 15,
    ),
    const RouteStop(
      id: 'stop-5',
      routeId: 'route-1',
      name: 'Mathare North',
      latitude: -1.2600,
      longitude: 36.8550,
      sequence: 4,
      estimatedTimeFromStart: 22,
    ),
    const RouteStop(
      id: 'stop-6',
      routeId: 'route-1',
      name: 'Eastleigh',
      latitude: -1.2700,
      longitude: 36.8600,
      sequence: 5,
      estimatedTimeFromStart: 30,
    ),
  ];

  return ActiveTrip(
    tripId: tripId ?? 'trip-001',
    bookingId: 'booking-001',
    vehicle: const TripVehicleInfo(
      id: 'vehicle-001',
      registrationNumber: 'KBZ 123A',
      make: 'Toyota',
      model: 'Hiace',
      color: 'White',
      capacity: 14,
    ),
    driver: const TripDriverInfo(
      id: 'driver-001',
      name: 'John Kamau',
      phone: '+254712345678',
      rating: 4.7,
    ),
    route: TripRouteInfo(
      id: 'route-1',
      name: 'Route 33 - CBD to Eastleigh',
      startPoint: 'CBD',
      endPoint: 'Eastleigh',
      stops: stops,
    ),
    pickupStop: stops[0], // CBD
    dropoffStop: stops[5], // Eastleigh
    currentVehiclePosition: VehiclePosition(
      latitude: -1.2750,
      longitude: 36.8300,
      heading: 45.0,
      speed: 28.5,
      updatedAt: DateTime.now(),
    ),
    status: ActiveTripStatus.inProgress,
    currentStopIndex: 2, // At Ngara
    estimatedArrival: DateTime.now().add(const Duration(minutes: 18)),
    distanceRemaining: 4.2,
    fare: 70.0,
    currency: 'KES',
    bookingReference: 'KMT-33-001',
    startedAt: DateTime.now().subtract(const Duration(minutes: 12)),
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
  );
}

/// Generate mock vehicle location stream.
Stream<VehiclePosition> _mockVehicleLocationStream() async* {
  double lat = -1.2750;
  double lng = 36.8300;
  double heading = 45.0;

  while (true) {
    await Future.delayed(const Duration(seconds: 3));

    // Simulate movement
    lat += 0.0002;
    lng += 0.0003;
    heading = (heading + 5) % 360;

    yield VehiclePosition(
      latitude: lat,
      longitude: lng,
      heading: heading,
      speed: 20.0 + (DateTime.now().second % 20),
      updatedAt: DateTime.now(),
    );
  }
}
