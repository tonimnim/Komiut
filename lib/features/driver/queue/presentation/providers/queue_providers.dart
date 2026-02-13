/// Queue providers for managing driver queue state.
///
/// Provides queue position, join/leave actions, and route queue data
/// with Riverpod state management. Depends on dashboard providers
/// to get the driver's vehicleId.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/repositories/queue_repository.dart';
import '../../domain/entities/queue_position.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Core Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the driver's current queue position.
///
/// Fetches the current queue position using the driver's vehicleId.
/// Returns null if the driver is not in any queue.
///
/// Depends on [driverProfileProvider] to get the vehicleId.
final driverQueuePositionProvider = FutureProvider<QueuePosition?>((ref) async {
  // Check mock state first (for testing flow)
  final mockPos = ref.watch(mockCurrentPositionProvider);
  if (mockPos != null) return mockPos;

  final profile = await ref.watch(driverProfileProvider.future);

  final vehicleId = profile.vehicleId;
  if (vehicleId == null) return null; // No vehicle assigned

  final repository = ref.watch(queueRepositoryProvider);
  final result = await repository.getQueuePosition(vehicleId);

  return result.fold(
    (failure) => null, // Not in queue or error
    (position) => position,
  );
});

/// Provider for all positions in a specific route's queue.
///
/// Fetches the full queue for a given route ID.
/// Useful for displaying the queue screen.
final routeQueueProvider =
    FutureProvider.family<List<QueuePosition>, String>((ref, routeId) async {
  final repository = ref.watch(queueRepositoryProvider);
  final result = await repository.getRouteQueue(routeId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (positions) => positions,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Derived Providers (Performance Optimized)
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for whether the driver is currently in a queue.
final isInQueueProvider = Provider<bool>((ref) {
  final positionAsync = ref.watch(driverQueuePositionProvider);
  return positionAsync.whenOrNull(data: (position) => position != null) ??
      false;
});

/// Provider for the driver's position number in queue.
///
/// Returns null if not in queue.
final queuePositionNumberProvider = Provider<int?>((ref) {
  final positionAsync = ref.watch(driverQueuePositionProvider);
  return positionAsync.whenOrNull(data: (position) => position?.position);
});

/// Provider for whether the driver is first in queue.
final isFirstInQueueProvider = Provider<bool>((ref) {
  final positionAsync = ref.watch(driverQueuePositionProvider);
  return positionAsync.whenOrNull(
        data: (position) => position?.isFirst ?? false,
      ) ??
      false;
});

/// Provider for the current queue's route name.
final queueRouteNameProvider = Provider<String?>((ref) {
  final positionAsync = ref.watch(driverQueuePositionProvider);
  return positionAsync.whenOrNull(data: (position) => position?.routeName);
});

/// Provider for estimated wait time display.
final queueEstimatedWaitProvider = Provider<String>((ref) {
  final positionAsync = ref.watch(driverQueuePositionProvider);
  return positionAsync.whenOrNull(
        data: (position) => position?.displayEstimatedWait ?? '--',
      ) ??
      '--';
});

/// Provider for vehicles ahead in queue.
final vehiclesAheadProvider = Provider<int?>((ref) {
  final positionAsync = ref.watch(driverQueuePositionProvider);
  return positionAsync.whenOrNull(data: (position) => position?.vehiclesAhead);
});

/// Provider for queue status.
final queueStatusProvider = Provider<QueueStatus?>((ref) {
  final positionAsync = ref.watch(driverQueuePositionProvider);
  return positionAsync.whenOrNull(data: (position) => position?.status);
});

/// Provider for whether the driver is currently boarding.
final isBoardingProvider = Provider<bool>((ref) {
  final positionAsync = ref.watch(driverQueuePositionProvider);
  return positionAsync.whenOrNull(
        data: (position) => position?.isBoarding ?? false,
      ) ??
      false;
});

// ─────────────────────────────────────────────────────────────────────────────
// State Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the selected route ID when joining a queue.
final selectedRouteIdProvider = StateProvider<String?>((ref) => null);

/// Provider for tracking queue operation loading state.
final queueOperationLoadingProvider = StateProvider<bool>((ref) => false);

/// Passenger count while loading passengers.
final passengerCountProvider = StateProvider<int>((ref) => 0);

/// Whether the driver is currently in the "loading passengers" phase.
///
/// This is a local UI state: after position=1, the driver taps
/// "Start Loading" which flips this to true. The UI then shows the
/// passenger counter and "Start Trip" button.
final isLoadingPassengersProvider = StateProvider<bool>((ref) => false);

/// Vehicle max capacity (mock value for now).
final vehicleMaxCapacityProvider = StateProvider<int>((ref) => 14);

// ─────────────────────────────────────────────────────────────────────────────
// External State Mocks (Simulating Home Screen)
// ─────────────────────────────────────────────────────────────────────────────

/// Mock provider for passenger count set externally (e.g. from Home Screen).
final mockExternalPassengerCountProvider = StateProvider<int>((ref) => 0);

/// Computed provider to check if vehicle is full based on external state.
final isVehicleFullProvider = Provider<bool>((ref) {
  final current = ref.watch(mockExternalPassengerCountProvider);
  final max = ref.watch(vehicleMaxCapacityProvider);
  return current >= max;
});

// ─────────────────────────────────────────────────────────────────────────────
// Action Providers
// ─────────────────────────────────────────────────────────────────────────────

// Mock state for debugging flow (so we can test without real backend)
final mockCurrentPositionProvider =
    StateProvider<QueuePosition?>((ref) => null);

/// Provider for joining a queue.
///
/// Joins the specified route's queue using the driver's vehicleId.
/// Returns the new [QueuePosition] on success.
///
/// Usage:
/// ```dart
/// final position = await ref.read(joinQueueProvider('route-123').future);
/// ```
final joinQueueProvider =
    FutureProvider.family<QueuePosition, String>((ref, routeId) async {
  // Mock logic for testing with mock routes
  if (['1', '2', '3'].contains(routeId)) {
    await Future.delayed(const Duration(seconds: 1)); // Fake network delay

    // Map mock route IDs to names
    final routeNames = {
      '1': 'Town - Westlands',
      '2': 'Town - Upperhill',
      '3': 'Town - Kilimani',
    };

    final newPosition = QueuePosition(
      id: 'mock-pos-$routeId',
      position: 4, // Start at position 4
      routeId: routeId,
      routeName: routeNames[routeId] ?? 'Route $routeId',
      joinedAt: DateTime.now(),
      status: QueueStatus.waiting,
      estimatedWaitMinutes: 20,
      vehiclesAhead: 3,
      vehicleRegistration: 'KDA 001K', // Mock plate
    );

    // Update local mock state
    ref.read(mockCurrentPositionProvider.notifier).state = newPosition;
    ref.invalidate(driverQueuePositionProvider);
    return newPosition;
  }

  final profile = await ref.watch(driverProfileProvider.future);

  final vehicleId = profile.vehicleId;
  if (vehicleId == null) {
    throw Exception('No vehicle assigned. Please contact your organization.');
  }

  final repository = ref.watch(queueRepositoryProvider);
  final result = await repository.joinQueue(
    vehicleId: vehicleId,
    routeId: routeId,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (position) {
      // Refresh current position
      ref.invalidate(driverQueuePositionProvider);
      return position;
    },
  );
});

/// Provider for leaving the current queue.
///
/// Removes the driver from their current queue.
///
/// Usage:
/// ```dart
/// await ref.read(leaveQueueProvider.future);
/// ```
final leaveQueueProvider = FutureProvider<void>((ref) async {
  // Clear mock state if exists
  if (ref.read(mockCurrentPositionProvider) != null) {
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(mockCurrentPositionProvider.notifier).state = null;
    ref.invalidate(driverQueuePositionProvider);
    return;
  }

  final profile = await ref.watch(driverProfileProvider.future);

  final vehicleId = profile.vehicleId;
  if (vehicleId == null) {
    throw Exception('No vehicle assigned. Please contact your organization.');
  }

  final repository = ref.watch(queueRepositoryProvider);
  final result = await repository.leaveQueue(vehicleId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) {
      // Refresh current position
      ref.invalidate(driverQueuePositionProvider);
    },
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Refresh Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Helper to refresh queue data.
///
/// Call this on pull-to-refresh or when returning to the queue screen.
void refreshQueue(WidgetRef ref) {
  ref.invalidate(driverQueuePositionProvider);

  // Also refresh route queue if a route is selected
  final selectedRoute = ref.read(selectedRouteIdProvider);
  if (selectedRoute != null) {
    ref.invalidate(routeQueueProvider(selectedRoute));
  }
}
