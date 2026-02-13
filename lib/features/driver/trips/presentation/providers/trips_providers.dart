/// Trips providers for managing driver trips state.
///
/// Provides trip list, active trip, and trip actions
/// with Riverpod state management. Depends on dashboard providers
/// to get the driver's vehicleId and profile.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/auth/presentation/providers/auth_controller.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/repositories/trips_repository.dart';
import '../../domain/entities/driver_trip.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

/// Filter for trip list display.
enum TripFilter {
  all,
  active,
  completed,
  cancelled;

  /// Display label for the filter.
  String get label => switch (this) {
        TripFilter.all => 'All',
        TripFilter.active => 'Active',
        TripFilter.completed => 'Completed',
        TripFilter.cancelled => 'Cancelled',
      };

  /// Convert to [DriverTripStatus] for API filtering.
  DriverTripStatus? get toStatus => switch (this) {
        TripFilter.all => null,
        TripFilter.active => DriverTripStatus.active,
        TripFilter.completed => DriverTripStatus.completed,
        TripFilter.cancelled => DriverTripStatus.cancelled,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// State Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the currently selected trip filter.
final selectedTripFilterProvider = StateProvider<TripFilter>(
  (ref) => TripFilter.all,
);

/// Provider for tracking trip operation loading state.
final tripOperationLoadingProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────────────────────────────────────────
// Core Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the driver's active trip.
///
/// Fetches the currently active trip using the driver's vehicleId.
/// Returns null if no trip is currently active.
///
/// Depends on [driverProfileProvider] to get the vehicleId.
final activeTripProvider = FutureProvider<DriverTrip?>((ref) async {
  final profile = await ref.watch(driverProfileProvider.future);

  if (!profile.hasVehicle) {
    return null;
  }

  final repository = ref.watch(tripsRepositoryProvider);
  final result = await repository.getActiveTrip(profile.vehicleId!);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (trip) => trip,
  );
});

/// Notifier that accumulates trip history pages.
class TripsHistoryNotifier extends StateNotifier<AsyncValue<List<DriverTrip>>> {
  TripsHistoryNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;
  int _currentPage = 1;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    _currentPage = 1;
    _hasMore = true;
    await _fetchPage(1, replace: true);
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    await _fetchPage(_currentPage + 1, replace: false);
  }

  Future<void> refresh() async {
    await _load();
  }

  Future<void> _fetchPage(int page, {required bool replace}) async {
    try {
      final profile = await _ref.read(driverProfileProvider.future);
      if (!profile.hasVehicle) {
        if (replace) state = const AsyncValue.data([]);
        return;
      }

      final filter = _ref.read(selectedTripFilterProvider);
      final repository = _ref.read(tripsRepositoryProvider);
      final result = await repository.getTrips(
        vehicleId: profile.vehicleId!,
        status: filter.toStatus,
        pageNumber: page,
        pageSize: 20,
      );

      result.fold(
        (failure) {
          if (replace) {
            state = AsyncValue.error(
                Exception(failure.message), StackTrace.current);
          }
        },
        (newItems) {
          _currentPage = page;
          _hasMore = newItems.length >= 20;
          final existing = replace ? <DriverTrip>[] : (state.value ?? []);
          state = AsyncValue.data([...existing, ...newItems]);
        },
      );
    } catch (e, st) {
      if (replace) {
        state = AsyncValue.error(e, st);
      }
    }
  }
}

/// Provider for the driver's trip history with pagination accumulation.
final tripsHistoryProvider =
    StateNotifierProvider<TripsHistoryNotifier, AsyncValue<List<DriverTrip>>>(
        (ref) {
  // Re-create when filter changes
  ref.watch(selectedTripFilterProvider);
  return TripsHistoryNotifier(ref);
});

/// Provider for a specific trip by ID.
///
/// Useful for trip detail screens.
final tripByIdProvider =
    FutureProvider.family<DriverTrip?, String>((ref, tripId) async {
  final profile = await ref.watch(driverProfileProvider.future);

  if (!profile.hasVehicle) {
    return null;
  }

  final repository = ref.watch(tripsRepositoryProvider);
  final result = await repository.getTrips(
    vehicleId: profile.vehicleId!,
    pageNumber: 1,
    pageSize: 100, // Get enough to find the trip
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (trips) => trips.where((t) => t.id == tripId).firstOrNull,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Derived Providers (Performance Optimized)
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for whether the driver has an active trip.
final hasActiveTripProvider = Provider<bool>((ref) {
  final tripAsync = ref.watch(activeTripProvider);
  return tripAsync.whenOrNull(data: (trip) => trip != null) ?? false;
});

/// Provider for the active trip's route name.
final activeTripRouteNameProvider = Provider<String?>((ref) {
  final tripAsync = ref.watch(activeTripProvider);
  return tripAsync.whenOrNull(data: (trip) => trip?.routeName);
});

/// Provider for the active trip's passenger count.
final activeTripPassengerCountProvider = Provider<int>((ref) {
  final tripAsync = ref.watch(activeTripProvider);
  return tripAsync.whenOrNull(data: (trip) => trip?.passengerCount ?? 0) ?? 0;
});

/// Provider for the active trip's status.
final activeTripStatusProvider = Provider<DriverTripStatus?>((ref) {
  final tripAsync = ref.watch(activeTripProvider);
  return tripAsync.whenOrNull(data: (trip) => trip?.status);
});

/// Provider for whether there are more pages to load.
final hasMoreTripsProvider = Provider<bool>((ref) {
  return ref.watch(tripsHistoryProvider.notifier).hasMore;
});

/// Provider for total trips count in current list.
final tripCountProvider = Provider<int>((ref) {
  final tripsAsync = ref.watch(tripsHistoryProvider);
  return tripsAsync.whenOrNull(data: (trips) => trips.length) ?? 0;
});

/// Provider for completed trips today.
final todayCompletedTripsProvider = FutureProvider<int>((ref) async {
  final profile = await ref.watch(driverProfileProvider.future);

  if (!profile.hasVehicle) {
    return 0;
  }

  final repository = ref.watch(tripsRepositoryProvider);
  final result = await repository.getTrips(
    vehicleId: profile.vehicleId!,
    status: DriverTripStatus.completed,
    pageNumber: 1,
    pageSize: 100,
  );

  return result.fold(
    (failure) => 0,
    (trips) {
      final today = DateTime.now();
      return trips
          .where((trip) =>
              trip.endTime != null &&
              trip.endTime!.year == today.year &&
              trip.endTime!.month == today.month &&
              trip.endTime!.day == today.day)
          .length;
    },
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Action Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Parameters for starting a trip.
class StartTripParams {
  const StartTripParams({
    required this.routeId,
    this.toutId,
  });

  final String routeId;
  final String? toutId;
}

/// Provider for starting a new trip.
///
/// Starts a trip on the specified route using the driver's vehicleId.
/// Returns the new [DriverTrip] on success.
///
/// Usage:
/// ```dart
/// final trip = await ref.read(
///   startTripProvider(StartTripParams(routeId: 'route-123')).future,
/// );
/// ```
final startTripProvider =
    FutureProvider.family<DriverTrip, StartTripParams>((ref, params) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final profile = await ref.watch(driverProfileProvider.future);

  if (!profile.hasVehicle) {
    throw Exception('No vehicle assigned to captain');
  }

  // Set loading state
  ref.read(tripOperationLoadingProvider.notifier).state = true;

  try {
    final repository = ref.watch(tripsRepositoryProvider);
    final result = await repository.startTrip(
      vehicleId: profile.vehicleId!,
      routeId: params.routeId,
      driverId: user.id,
      toutId: params.toutId,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (trip) {
        // Refresh active trip and history
        ref.invalidate(activeTripProvider);
        ref.invalidate(tripsHistoryProvider);
        return trip;
      },
    );
  } finally {
    ref.read(tripOperationLoadingProvider.notifier).state = false;
  }
});

/// Parameters for ending a trip.
class EndTripParams {
  const EndTripParams({
    required this.tripId,
    this.reason,
  });

  final String tripId;
  final String? reason;
}

/// Provider for ending the current trip.
///
/// Ends the specified trip.
///
/// Usage:
/// ```dart
/// await ref.read(
///   endTripProvider(EndTripParams(tripId: 'trip-123')).future,
/// );
/// ```
final endTripProvider =
    FutureProvider.family<void, EndTripParams>((ref, params) async {
  // Set loading state
  ref.read(tripOperationLoadingProvider.notifier).state = true;

  try {
    final repository = ref.watch(tripsRepositoryProvider);
    final result = await repository.endTrip(
      tripId: params.tripId,
      reason: params.reason,
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        // Refresh active trip and history
        ref.invalidate(activeTripProvider);
        ref.invalidate(tripsHistoryProvider);
        // Also refresh earnings since trip completion affects earnings
        // This is imported at the top if needed, or we can use string invalidation
      },
    );
  } finally {
    ref.read(tripOperationLoadingProvider.notifier).state = false;
  }
});

/// Parameters for updating trip status.
class UpdateTripStatusParams {
  const UpdateTripStatusParams({
    required this.tripId,
    required this.status,
    this.reason,
  });

  final String tripId;
  final DriverTripStatus status;
  final String? reason;
}

/// Provider for updating trip status.
///
/// Updates the status of a specific trip.
///
/// Usage:
/// ```dart
/// await ref.read(
///   updateTripStatusProvider(UpdateTripStatusParams(
///     tripId: 'trip-123',
///     status: DriverTripStatus.cancelled,
///     reason: 'Vehicle breakdown',
///   )).future,
/// );
/// ```
final updateTripStatusProvider =
    FutureProvider.family<void, UpdateTripStatusParams>((ref, params) async {
  // Set loading state
  ref.read(tripOperationLoadingProvider.notifier).state = true;

  try {
    final repository = ref.watch(tripsRepositoryProvider);
    final result = await repository.updateTripStatus(
      tripId: params.tripId,
      status: params.status,
      reason: params.reason,
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        // Refresh active trip and history
        ref.invalidate(activeTripProvider);
        ref.invalidate(tripsHistoryProvider);
      },
    );
  } finally {
    ref.read(tripOperationLoadingProvider.notifier).state = false;
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// Refresh Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Helper to refresh all trips data.
///
/// Call this on pull-to-refresh or when returning to the trips screen.
void refreshTrips(WidgetRef ref) {
  ref.invalidate(activeTripProvider);
  ref.invalidate(todayCompletedTripsProvider);
  ref.read(tripsHistoryProvider.notifier).refresh();
}

/// Helper to load the next page of trip history.
void loadMoreTrips(WidgetRef ref) {
  ref.read(tripsHistoryProvider.notifier).loadMore();
}
