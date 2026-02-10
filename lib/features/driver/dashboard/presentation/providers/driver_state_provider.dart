/// Driver state provider for state-driven UI.
///
/// Derives the current driver state from existing providers to show
/// appropriate UI without unnecessary rebuilds.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../queue/domain/entities/queue_position.dart';
import '../../../trips/domain/entities/driver_trip.dart';

import '../../../queue/presentation/providers/queue_providers.dart';
import '../../../trips/presentation/providers/trips_providers.dart';
import 'dashboard_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver State Enum
// ─────────────────────────────────────────────────────────────────────────────

/// The current state of the driver.
///
/// Used to drive the UI and show relevant content based on what
/// the driver is currently doing.
enum DriverState {
  /// Initial loading state - data is being fetched.
  loading,

  /// Driver is idle - not in queue, no active trip.
  idle,

  /// Driver is in a queue waiting for their turn.
  inQueue,

  /// Driver has an active trip in progress.
  onTrip,
}

// ─────────────────────────────────────────────────────────────────────────────
// State Data Class
// ─────────────────────────────────────────────────────────────────────────────

/// Combined state data for the driver home screen.
///
/// Contains the derived state and any relevant data needed for display.
class DriverStateData {
  const DriverStateData({
    required this.state,
    this.queuePosition,
    this.activeTrip,
    this.isOnline = false,
    this.error,
  });

  /// The current driver state.
  final DriverState state;

  /// Queue position if in queue.
  final QueuePosition? queuePosition;

  /// Active trip if on trip.
  final DriverTrip? activeTrip;

  /// Whether the driver is online.
  final bool isOnline;

  /// Error message if any.
  final String? error;

  /// Whether there's an error.
  bool get hasError => error != null;

  /// Creates a loading state.
  const DriverStateData.loading()
      : state = DriverState.loading,
        queuePosition = null,
        activeTrip = null,
        isOnline = false,
        error = null;

  /// Creates an idle state.
  const DriverStateData.idle({this.isOnline = false})
      : state = DriverState.idle,
        queuePosition = null,
        activeTrip = null,
        error = null;

  /// Creates an in-queue state.
  DriverStateData.inQueue({
    required QueuePosition queue,
    this.isOnline = false,
  })  : state = DriverState.inQueue,
        queuePosition = queue,
        activeTrip = null,
        error = null;

  /// Creates an on-trip state.
  DriverStateData.onTrip({
    required DriverTrip trip,
    this.isOnline = false,
  })  : state = DriverState.onTrip,
        queuePosition = null,
        activeTrip = trip,
        error = null;

  /// Creates an error state (falls back to idle).
  const DriverStateData.error(this.error)
      : state = DriverState.idle,
        queuePosition = null,
        activeTrip = null,
        isOnline = false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Main State Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the derived driver state.
///
/// This provider watches the underlying data providers and derives
/// the current state. Uses `.select()` internally to minimize rebuilds.
///
/// Priority order:
/// 1. Active trip takes precedence (onTrip)
/// 2. Queue position is next (inQueue)
/// 3. Otherwise idle
final driverStateProvider = Provider<DriverStateData>((ref) {
  // Watch online status separately for efficiency
  final isOnline = ref.watch(
    driverProfileProvider.select(
      (async) => async.whenOrNull(data: (p) => p.isOnline) ?? false,
    ),
  );

  // Check active trip first (highest priority)
  final tripAsync = ref.watch(activeTripProvider);

  // If trip provider is loading, check if queue is also loading
  if (tripAsync.isLoading) {
    final queueAsync = ref.watch(driverQueuePositionProvider);
    if (queueAsync.isLoading) {
      return const DriverStateData.loading();
    }
  }

  // Check for active trip
  final activeTrip = tripAsync.whenOrNull(data: (trip) => trip);
  if (activeTrip != null) {
    return DriverStateData.onTrip(trip: activeTrip, isOnline: isOnline);
  }

  // Check for queue position
  final queueAsync = ref.watch(driverQueuePositionProvider);

  if (queueAsync.isLoading && tripAsync.isLoading) {
    return const DriverStateData.loading();
  }

  final queuePosition = queueAsync.whenOrNull(data: (pos) => pos);
  if (queuePosition != null) {
    return DriverStateData.inQueue(queue: queuePosition, isOnline: isOnline);
  }

  // Check for errors
  final tripError = tripAsync.whenOrNull(error: (e, _) => e.toString());
  final queueError = queueAsync.whenOrNull(error: (e, _) => e.toString());

  if (tripError != null || queueError != null) {
    return DriverStateData.error(tripError ?? queueError);
  }

  // Default to idle
  return DriverStateData.idle(isOnline: isOnline);
});

// ─────────────────────────────────────────────────────────────────────────────
// Selective Providers (For Granular Rebuilds)
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for just the driver state enum.
///
/// Use this when you only need to know the state, not the data.
final driverStateEnumProvider = Provider<DriverState>((ref) {
  return ref.watch(driverStateProvider.select((s) => s.state));
});

/// Provider for whether the driver is currently loading.
final isDriverLoadingProvider = Provider<bool>((ref) {
  return ref
      .watch(driverStateProvider.select((s) => s.state == DriverState.loading));
});

/// Provider for whether the driver is idle.
final isDriverIdleProvider = Provider<bool>((ref) {
  return ref
      .watch(driverStateProvider.select((s) => s.state == DriverState.idle));
});

/// Provider for whether the driver is in queue.
final isDriverInQueueProvider = Provider<bool>((ref) {
  return ref
      .watch(driverStateProvider.select((s) => s.state == DriverState.inQueue));
});

/// Provider for whether the driver is on a trip.
final isDriverOnTripProvider = Provider<bool>((ref) {
  return ref
      .watch(driverStateProvider.select((s) => s.state == DriverState.onTrip));
});
