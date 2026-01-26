/// Sacco providers for managing Sacco state.
///
/// Provides Sacco data with Riverpod state management for the
/// passenger discovery feature. Includes providers for listing,
/// searching, and filtering Saccos.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/sacco_repository.dart';
import '../../domain/entities/sacco.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for fetching all Saccos.
///
/// Fetches the list of all available Saccos from the API.
/// Returns an empty list on error (errors are logged but not thrown
/// to allow graceful UI handling).
final saccosProvider = FutureProvider<List<Sacco>>((ref) async {
  final repository = ref.watch(saccoRepositoryProvider);
  final result = await repository.getSaccos();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (saccos) => saccos,
  );
});

/// Provider for fetching a single Sacco by ID.
///
/// [saccoId] - The unique identifier of the Sacco to fetch.
/// Returns the [Sacco] entity or throws on error.
final saccoByIdProvider =
    FutureProvider.family<Sacco, String>((ref, saccoId) async {
  final repository = ref.watch(saccoRepositoryProvider);
  final result = await repository.getSaccoById(saccoId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (sacco) => sacco,
  );
});

/// Provider for fetching Saccos that operate on a specific route.
///
/// [routeId] - The unique identifier of the route.
/// Returns a list of [Sacco] entities that operate on the route.
final saccosByRouteProvider =
    FutureProvider.family<List<Sacco>, String>((ref, routeId) async {
  final repository = ref.watch(saccoRepositoryProvider);
  final result = await repository.getSaccosByRoute(routeId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (saccos) => saccos,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Search & Filter Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the current Sacco search query.
///
/// Used to filter the list of Saccos in the UI.
final saccoSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered Saccos based on search query.
///
/// Combines the Sacco list with the search query to provide
/// a filtered list. Filters by name and description.
final filteredSaccosProvider = Provider<AsyncValue<List<Sacco>>>((ref) {
  final saccosAsync = ref.watch(saccosProvider);
  final query = ref.watch(saccoSearchQueryProvider).toLowerCase().trim();

  return saccosAsync.whenData((saccos) {
    if (query.isEmpty) return saccos;

    return saccos.where((sacco) {
      final nameMatch = sacco.name.toLowerCase().contains(query);
      final descriptionMatch =
          sacco.description?.toLowerCase().contains(query) ?? false;
      return nameMatch || descriptionMatch;
    }).toList();
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Selection Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the currently selected Sacco.
///
/// Used when navigating to Sacco details or when selecting
/// a Sacco for booking purposes.
final selectedSaccoProvider = StateProvider<Sacco?>((ref) => null);

// ─────────────────────────────────────────────────────────────────────────────
// Filter Options Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for filtering Saccos by active status.
///
/// When true, only shows active Saccos.
final showActiveSaccosOnlyProvider = StateProvider<bool>((ref) => true);

/// Provider for Saccos filtered by active status.
///
/// Combines the filtered Saccos with the active-only filter.
final activeSaccosProvider = Provider<AsyncValue<List<Sacco>>>((ref) {
  final filteredAsync = ref.watch(filteredSaccosProvider);
  final showActiveOnly = ref.watch(showActiveSaccosOnlyProvider);

  return filteredAsync.whenData((saccos) {
    if (!showActiveOnly) return saccos;
    return saccos.where((sacco) => sacco.isActive).toList();
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Utility Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for counting total Saccos.
///
/// Returns the total count of all Saccos (before filtering).
final saccosCountProvider = Provider<int>((ref) {
  final saccosAsync = ref.watch(saccosProvider);
  return saccosAsync.whenOrNull(data: (saccos) => saccos.length) ?? 0;
});

/// Provider for counting active Saccos.
///
/// Returns the count of active Saccos only.
final activeSaccosCountProvider = Provider<int>((ref) {
  final saccosAsync = ref.watch(saccosProvider);
  return saccosAsync.whenOrNull(
        data: (saccos) => saccos.where((s) => s.isActive).length,
      ) ??
      0;
});
