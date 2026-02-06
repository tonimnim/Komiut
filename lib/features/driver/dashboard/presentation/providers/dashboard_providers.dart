/// Dashboard providers for managing driver dashboard state.
///
/// Provides driver profile, stats, and online status management
/// with Riverpod state management. These providers are foundational
/// for the driver feature - other features depend on the driver profile
/// to get the vehicleId for their API calls.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/auth/presentation/providers/auth_controller.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../domain/entities/driver_profile.dart';
import '../../domain/entities/driver_stats.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Core Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the current driver's profile.
///
/// Fetches the driver profile using the authenticated user's ID.
/// This is a foundational provider - other driver features depend on it
/// to get the vehicleId for their API calls.
///
/// Returns the [DriverProfile] entity or throws on error.
final driverProfileProvider = FutureProvider<DriverProfile>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final repository = ref.watch(dashboardRepositoryProvider);
  final result = await repository.getDriverProfile(user.id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (profile) => profile,
  );
});

/// Provider for driver statistics.
///
/// Fetches stats using the driver's vehicleId from their profile.
/// Depends on [driverProfileProvider] to get the vehicleId.
///
/// Returns [DriverStats] entity or throws on error.
final driverStatsProvider = FutureProvider<DriverStats>((ref) async {
  final profile = await ref.watch(driverProfileProvider.future);

  if (!profile.hasVehicle) {
    throw Exception('No vehicle assigned to captain');
  }

  final repository = ref.watch(dashboardRepositoryProvider);
  final result = await repository.getDriverStats(profile.vehicleId!);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Derived Providers (Performance Optimized)
// Use these to minimize rebuilds when you only need specific data
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for just the driver's name.
///
/// Use this instead of [driverProfileProvider] when you only need the name
/// to avoid unnecessary rebuilds.
final driverNameProvider = Provider<AsyncValue<String>>((ref) {
  return ref.watch(driverProfileProvider).whenData((profile) => profile.fullName);
});

/// Provider for the driver's vehicle ID.
///
/// Returns null if no vehicle is assigned.
/// Other features use this to fetch vehicle-specific data.
final driverVehicleIdProvider = Provider<AsyncValue<String?>>((ref) {
  return ref.watch(driverProfileProvider).whenData((profile) => profile.vehicleId);
});

/// Provider for whether the driver has a vehicle assigned.
final driverHasVehicleProvider = Provider<bool>((ref) {
  final profileAsync = ref.watch(driverProfileProvider);
  return profileAsync.whenOrNull(data: (profile) => profile.hasVehicle) ?? false;
});

/// Provider for whether the driver can accept trips.
///
/// Returns true only if the driver is verified, has a vehicle, and belongs to a sacco.
final driverCanAcceptTripsProvider = Provider<bool>((ref) {
  final profileAsync = ref.watch(driverProfileProvider);
  return profileAsync.whenOrNull(data: (profile) => profile.canAcceptTrips) ?? false;
});

/// Provider for the driver's rating.
final driverRatingProvider = Provider<AsyncValue<String>>((ref) {
  return ref.watch(driverProfileProvider).whenData((profile) => profile.displayRating);
});

// ─────────────────────────────────────────────────────────────────────────────
// State Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for driver's online/offline status.
///
/// This is local state that can be toggled by the driver.
/// The actual update is handled by [updateOnlineStatusProvider].
final isDriverOnlineProvider = StateProvider<bool>((ref) {
  // Initialize from profile if available
  final profileAsync = ref.watch(driverProfileProvider);
  return profileAsync.whenOrNull(data: (profile) => profile.isOnline) ?? false;
});

// ─────────────────────────────────────────────────────────────────────────────
// Action Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for updating driver's online status.
///
/// Call this when the driver toggles their online/offline status.
/// Updates the backend and refreshes the profile on success.
///
/// Usage:
/// ```dart
/// ref.read(updateOnlineStatusProvider(true));
/// ```
final updateOnlineStatusProvider =
    FutureProvider.family<void, bool>((ref, isOnline) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final repository = ref.watch(dashboardRepositoryProvider);
  final result = await repository.updateOnlineStatus(
    personnelId: user.id,
    isOnline: isOnline,
  );

  result.fold(
    (failure) => throw Exception(failure.message),
    (_) {
      // Update local state
      ref.read(isDriverOnlineProvider.notifier).state = isOnline;
      // Refresh profile to get updated data
      ref.invalidate(driverProfileProvider);
    },
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Refresh Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Helper to refresh all dashboard data.
///
/// Call this on pull-to-refresh or when returning to the dashboard.
void refreshDashboard(WidgetRef ref) {
  ref.invalidate(driverProfileProvider);
  ref.invalidate(driverStatsProvider);
}
