/// Trips providers.
///
/// Provides state management for trips feature using Riverpod.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/home/domain/entities/trip_entity.dart';
import '../../data/models/trip_api_model.dart';
import '../../data/repositories/trips_repository.dart';

/// Provider for all trips with pagination and filters.
///
/// Usage:
/// ```dart
/// final trips = ref.watch(tripsProvider(TripsFilter(status: 'completed')));
/// ```
final tripsProvider =
    FutureProvider.autoDispose.family<List<TripEntity>, TripsFilter>(
  (ref, filter) async {
    final authState = ref.watch(authStateProvider);
    final repository = ref.watch(tripsRepositoryProvider);

    if (authState.user == null) return [];

    // Use the filter's passengerId if provided, otherwise use current user
    final passengerId = filter.passengerId ?? authState.user!.id.toString();

    final result = await repository.getTrips(
      passengerId: passengerId,
      status: filter.status,
      pageNumber: filter.pageNumber,
      pageSize: filter.pageSize,
    );

    return result.fold(
      (failure) => [],
      (trips) => trips,
    );
  },
);

/// Provider for a single trip detail.
///
/// Usage:
/// ```dart
/// final trip = ref.watch(tripDetailProvider('trip-id-123'));
/// ```
final tripDetailProvider =
    FutureProvider.autoDispose.family<TripEntity?, String>(
  (ref, tripId) async {
    final repository = ref.watch(tripsRepositoryProvider);

    final result = await repository.getTripById(tripId);

    return result.fold(
      (failure) => null,
      (trip) => trip,
    );
  },
);

/// Provider for recent trips (used on home screen).
///
/// This fetches the most recent trips for the current user.
/// Uses remote API with local fallback.
final recentTripsApiProvider = FutureProvider.autoDispose<List<TripEntity>>(
  (ref) async {
    final authState = ref.watch(authStateProvider);
    final repository = ref.watch(tripsRepositoryProvider);

    if (authState.user == null) return [];

    final result = await repository.getRecentTrips(
      authState.user!.id.toString(),
      limit: 5,
    );

    return result.fold(
      (failure) => [],
      (trips) => trips,
    );
  },
);

/// Provider for all trips (used on activity screen).
///
/// This fetches all trips for the current user.
/// Uses remote API with local fallback.
final allTripsApiProvider = FutureProvider.autoDispose<List<TripEntity>>(
  (ref) async {
    final authState = ref.watch(authStateProvider);
    final repository = ref.watch(tripsRepositoryProvider);

    if (authState.user == null) return [];

    final result = await repository.getAllTrips(authState.user!.id.toString());

    return result.fold(
      (failure) => [],
      (trips) => trips,
    );
  },
);

/// Provider for completed trips only.
final completedTripsProvider = FutureProvider.autoDispose<List<TripEntity>>(
  (ref) async {
    final authState = ref.watch(authStateProvider);
    final repository = ref.watch(tripsRepositoryProvider);

    if (authState.user == null) return [];

    final result = await repository.getTrips(
      passengerId: authState.user!.id.toString(),
      status: 'completed',
    );

    return result.fold(
      (failure) => [],
      (trips) => trips,
    );
  },
);

/// Provider for pending/active trips.
final activeTripsProvider = FutureProvider.autoDispose<List<TripEntity>>(
  (ref) async {
    final authState = ref.watch(authStateProvider);
    final repository = ref.watch(tripsRepositoryProvider);

    if (authState.user == null) return [];

    // Get confirmed bookings (active trips)
    final result = await repository.getTrips(
      passengerId: authState.user!.id.toString(),
      status: 'confirmed',
    );

    return result.fold(
      (failure) => [],
      (trips) => trips,
    );
  },
);
