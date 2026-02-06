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
  final profile = await ref.watch(driverProfileProvider.future);

  if (!profile.hasVehicle) {
    return null;
  }

  final repository = ref.watch(queueRepositoryProvider);
  final result = await repository.getQueuePosition(profile.vehicleId!);

  return result.fold(
    (failure) => throw Exception(failure.message),
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
  return positionAsync.whenOrNull(data: (position) => position != null) ?? false;
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

// ─────────────────────────────────────────────────────────────────────────────
// Action Providers
// ─────────────────────────────────────────────────────────────────────────────

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
  final profile = await ref.watch(driverProfileProvider.future);

  if (!profile.hasVehicle) {
    throw Exception('No vehicle assigned to driver');
  }

  // Set loading state
  ref.read(queueOperationLoadingProvider.notifier).state = true;

  try {
    final repository = ref.watch(queueRepositoryProvider);
    final result = await repository.joinQueue(
      vehicleId: profile.vehicleId!,
      routeId: routeId,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (position) {
        // Update selected route
        ref.read(selectedRouteIdProvider.notifier).state = routeId;
        // Refresh queue position
        ref.invalidate(driverQueuePositionProvider);
        return position;
      },
    );
  } finally {
    ref.read(queueOperationLoadingProvider.notifier).state = false;
  }
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
  final profile = await ref.watch(driverProfileProvider.future);

  if (!profile.hasVehicle) {
    throw Exception('No vehicle assigned to driver');
  }

  // Set loading state
  ref.read(queueOperationLoadingProvider.notifier).state = true;

  try {
    final repository = ref.watch(queueRepositoryProvider);
    final result = await repository.leaveQueue(profile.vehicleId!);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        // Clear selected route
        ref.read(selectedRouteIdProvider.notifier).state = null;
        // Refresh queue position
        ref.invalidate(driverQueuePositionProvider);
      },
    );
  } finally {
    ref.read(queueOperationLoadingProvider.notifier).state = false;
  }
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
