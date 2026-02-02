/// Route providers for managing route state.
///
/// Provides route data with API-first approach and local database fallback.
/// Supports fetching routes, route stops, and route fares.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/database_providers.dart';
import '../../../../../core/database/seed_data.dart';
import '../../../../../core/domain/entities/route.dart';
import '../../../../../core/domain/entities/route_fare.dart';
import '../../../../../core/domain/entities/route_stop.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/routes_remote_datasource.dart';
import '../../domain/entities/route_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for fetching all routes.
///
/// Tries to fetch from API first, falls back to local database if API fails.
/// The routes are also mapped to [RouteEntity] for UI compatibility.
final routesProvider = FutureProvider<List<RouteEntity>>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  final authState = ref.watch(authStateProvider);
  final userId = authState.user?.id;
  final remoteDataSource = ref.watch(routesRemoteDataSourceProvider);

  // Get favorites for current user
  Set<int> favoriteIds = {};
  if (userId != null) {
    final favorites = await database.getFavoriteRoutes(userId);
    favoriteIds = favorites.map((f) => f.id).toSet();
  }

  // Try fetching from API first
  final remoteResult = await remoteDataSource.getRoutes();

  return remoteResult.fold(
    (failure) async {
      // API failed, fall back to local database
      // Seed routes if not exist
      final seeder = DatabaseSeeder(database);
      await seeder.seedRoutes();

      final dbRoutes = await database.getAllRoutes();
      return dbRoutes.map((dbRoute) {
        return RouteEntity.fromDatabase(
          dbRoute,
          isFavorite: favoriteIds.contains(dbRoute.id),
        );
      }).toList();
    },
    (routes) {
      // API succeeded, convert TransportRoute to RouteEntity
      return routes.map((route) {
        return _transportRouteToEntity(
          route,
          isFavorite: favoriteIds.contains(int.tryParse(route.id) ?? 0),
        );
      }).toList();
    },
  );
});

/// Provider for fetching routes from API only.
///
/// Returns [TransportRoute] entities directly from the API.
/// Use this when you need the full route data structure.
final apiRoutesProvider = FutureProvider<List<TransportRoute>>((ref) async {
  final remoteDataSource = ref.watch(routesRemoteDataSourceProvider);
  final result = await remoteDataSource.getRoutes();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (routes) => routes,
  );
});

/// Provider for fetching a single route by ID from API.
///
/// [routeId] - The unique identifier of the route.
/// Returns [TransportRoute] entity or throws on error.
final apiRouteByIdProvider =
    FutureProvider.family<TransportRoute, String>((ref, routeId) async {
  final remoteDataSource = ref.watch(routesRemoteDataSourceProvider);
  final result = await remoteDataSource.getRouteById(routeId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (route) => route,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Route Stops Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for fetching stops for a specific route.
///
/// [routeId] - The unique identifier of the route.
/// Returns a sorted list of [RouteStop] entities.
final routeStopsProvider =
    FutureProvider.family<List<RouteStop>, String>((ref, routeId) async {
  final remoteDataSource = ref.watch(routesRemoteDataSourceProvider);
  final result = await remoteDataSource.getRouteStops(routeId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (stops) => stops,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Route Fares Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for fetching fares for a specific route.
///
/// [routeId] - The unique identifier of the route.
/// Returns a list of [RouteFare] entities.
final routeFaresProvider =
    FutureProvider.family<List<RouteFare>, String>((ref, routeId) async {
  final remoteDataSource = ref.watch(routesRemoteDataSourceProvider);
  final result = await remoteDataSource.getRouteFares(routeId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (fares) => fares,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Search & Filter Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the current search query.
final routeSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered routes based on search query.
///
/// Filters routes by name, start point, or end point.
final filteredRoutesProvider = Provider<AsyncValue<List<RouteEntity>>>((ref) {
  final routesAsync = ref.watch(routesProvider);
  final query = ref.watch(routeSearchQueryProvider).toLowerCase();

  return routesAsync.whenData((routes) {
    if (query.isEmpty) return routes;

    return routes.where((route) {
      return route.name.toLowerCase().contains(query) ||
          route.startPoint.toLowerCase().contains(query) ||
          route.endPoint.toLowerCase().contains(query);
    }).toList();
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Sacco Integration & Discovery Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the currently selected sacco filter.
///
/// Used by the routes screen to filter routes by a specific sacco.
/// Null means no sacco filter is applied.
final selectedSaccoFilterProvider = StateProvider<String?>((ref) => null);

/// Filter routes by sacco/organization ID.
///
/// Returns all routes operated by the specified organization (sacco).
/// [saccoId] - The unique identifier of the sacco/organization.
final routesBySaccoProvider =
    FutureProvider.family<List<RouteEntity>, String>((ref, saccoId) async {
  final routes = await ref.watch(routesProvider.future);
  return routes.where((route) => route.organizationId == saccoId).toList();
});

/// Popular routes provider.
///
/// Returns a list of routes marked as popular or featured.
/// Sorts by popularity if available, otherwise falls back to the first 5 routes.
/// Routes marked as favorites are also included as they indicate popularity.
final popularRoutesProvider = FutureProvider<List<RouteEntity>>((ref) async {
  final routes = await ref.watch(routesProvider.future);

  // Get routes marked as popular or favorited (user engagement indicator)
  final popularRoutes =
      routes.where((route) => route.isPopular || route.isFavorite).toList();

  // If we have popular routes, sort favorites first, then by name
  if (popularRoutes.isNotEmpty) {
    popularRoutes.sort((a, b) {
      // Favorites first
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      // Then popular
      if (a.isPopular && !b.isPopular) return -1;
      if (!a.isPopular && b.isPopular) return 1;
      return a.name.compareTo(b.name);
    });
    return popularRoutes.take(5).toList();
  }

  // If no popular routes are marked, return the first 5 routes as "popular"
  return routes.take(5).toList();
});

/// Routes filtered by destination search.
///
/// Searches routes where the destination (end point) matches the search query.
/// [destination] - The destination name to search for.
final routesByDestinationProvider =
    FutureProvider.family<List<RouteEntity>, String>((ref, destination) async {
  final routes = await ref.watch(routesProvider.future);
  final query = destination.toLowerCase();

  if (query.isEmpty) return routes;

  return routes.where((route) {
    return route.endPoint.toLowerCase().contains(query) ||
        route.stops.any((stop) => stop.toLowerCase().contains(query));
  }).toList();
});

/// State class for combined route filtering.
///
/// Holds all filter criteria that can be applied to the routes list.
class RouteFilterState {
  /// Creates a new route filter state.
  const RouteFilterState({
    this.saccoId,
    this.searchQuery,
    this.destinationFilter,
  });

  /// Filter by sacco/organization ID.
  final String? saccoId;

  /// General search query for route name, start point, or end point.
  final String? searchQuery;

  /// Filter by destination/end point.
  final String? destinationFilter;

  /// Whether any filters are active.
  bool get hasActiveFilters =>
      saccoId != null ||
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      (destinationFilter != null && destinationFilter!.isNotEmpty);

  /// Creates a copy with modified fields.
  RouteFilterState copyWith({
    String? saccoId,
    String? searchQuery,
    String? destinationFilter,
    bool clearSaccoId = false,
    bool clearSearchQuery = false,
    bool clearDestinationFilter = false,
  }) {
    return RouteFilterState(
      saccoId: clearSaccoId ? null : (saccoId ?? this.saccoId),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      destinationFilter: clearDestinationFilter
          ? null
          : (destinationFilter ?? this.destinationFilter),
    );
  }

  /// Creates a cleared filter state.
  RouteFilterState clear() {
    return const RouteFilterState();
  }
}

/// Provider for the combined route filter state.
///
/// Use this to manage all route filters in a single place.
final routeFilterStateProvider = StateProvider<RouteFilterState>((ref) {
  return const RouteFilterState();
});

/// Advanced filtered routes combining all filter criteria.
///
/// Watches the [routeFilterStateProvider] and applies all active filters
/// to the routes list. Filters are applied in order: sacco, search query,
/// destination.
final advancedFilteredRoutesProvider =
    Provider<AsyncValue<List<RouteEntity>>>((ref) {
  final filterState = ref.watch(routeFilterStateProvider);
  final allRoutes = ref.watch(routesProvider);

  return allRoutes.whenData((routes) {
    var filtered = routes;

    // Filter by sacco/organization
    if (filterState.saccoId != null) {
      filtered = filtered
          .where((r) => r.organizationId == filterState.saccoId)
          .toList();
    }

    // Filter by search query (name, start point, end point)
    if (filterState.searchQuery != null &&
        filterState.searchQuery!.isNotEmpty) {
      final query = filterState.searchQuery!.toLowerCase();
      filtered = filtered.where((r) {
        return r.name.toLowerCase().contains(query) ||
            r.startPoint.toLowerCase().contains(query) ||
            r.endPoint.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by destination
    if (filterState.destinationFilter != null &&
        filterState.destinationFilter!.isNotEmpty) {
      final destQuery = filterState.destinationFilter!.toLowerCase();
      filtered = filtered.where((r) {
        return r.endPoint.toLowerCase().contains(destQuery) ||
            r.stops.any((stop) => stop.toLowerCase().contains(destQuery));
      }).toList();
    }

    return filtered;
  });
});

/// Provider for unique destinations from all routes.
///
/// Returns a list of all unique end points and stops from routes,
/// useful for destination autocomplete suggestions.
final routeDestinationsProvider = FutureProvider<List<String>>((ref) async {
  final routes = await ref.watch(routesProvider.future);
  final destinations = <String>{};

  for (final route in routes) {
    destinations.add(route.endPoint);
    destinations.addAll(route.stops);
  }

  return destinations.toList()..sort();
});

// ─────────────────────────────────────────────────────────────────────────────
// Selection & Booking State
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the currently selected route.
final selectedRouteProvider = StateProvider<RouteEntity?>((ref) => null);

/// State class for booking information.
class BookingState {
  /// Creates a new booking state.
  const BookingState({
    this.fromStopIndex,
    this.toStopIndex,
    this.fare = 0,
  });

  /// Index of the departure stop.
  final int? fromStopIndex;

  /// Index of the destination stop.
  final int? toStopIndex;

  /// Calculated fare for the journey.
  final double fare;

  /// Whether the booking state is valid for proceeding.
  bool get isValid =>
      fromStopIndex != null &&
      toStopIndex != null &&
      fromStopIndex != toStopIndex;

  /// Creates a copy with modified fields.
  BookingState copyWith({
    int? fromStopIndex,
    int? toStopIndex,
    double? fare,
  }) {
    return BookingState(
      fromStopIndex: fromStopIndex ?? this.fromStopIndex,
      toStopIndex: toStopIndex ?? this.toStopIndex,
      fare: fare ?? this.fare,
    );
  }
}

/// Provider for managing booking state.
final bookingStateProvider =
    StateNotifierProvider<BookingStateNotifier, BookingState>((ref) {
  return BookingStateNotifier(ref);
});

/// Notifier for booking state changes.
class BookingStateNotifier extends StateNotifier<BookingState> {
  /// Creates a booking state notifier.
  BookingStateNotifier(this._ref) : super(const BookingState());

  final Ref _ref;

  /// Selects the departure stop.
  void selectFromStop(int index) {
    state = state.copyWith(fromStopIndex: index);
    _calculateFare();
  }

  /// Selects the destination stop.
  void selectToStop(int index) {
    state = state.copyWith(toStopIndex: index);
    _calculateFare();
  }

  void _calculateFare() {
    final route = _ref.read(selectedRouteProvider);
    if (route == null ||
        state.fromStopIndex == null ||
        state.toStopIndex == null) {
      state = state.copyWith(fare: 0);
      return;
    }

    final fare = route.calculateFare(state.fromStopIndex!, state.toStopIndex!);
    state = state.copyWith(fare: fare);
  }

  /// Resets the booking state.
  void reset() {
    state = const BookingState();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Favorites
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for toggling a route as favorite.
final toggleFavoriteProvider =
    Provider<Future<void> Function(RouteEntity)>((ref) {
  return (route) async {
    final database = ref.read(appDatabaseProvider);
    final authState = ref.read(authStateProvider);
    final userId = authState.user?.id;

    if (userId == null) return;

    if (route.isFavorite) {
      await database.removeFavoriteRoute(userId, route.id);
    } else {
      await database.addFavoriteRoute(userId, route.id);
    }

    // Refresh routes
    ref.invalidate(routesProvider);
  };
});

/// Provider for watching if a route is a favorite.
final routeFavoriteProvider = StreamProvider.family<bool, int>((ref, routeId) {
  final database = ref.watch(appDatabaseProvider);
  final authState = ref.watch(authStateProvider);
  final userId = authState.user?.id;

  if (userId == null) return Stream.value(false);

  return database.watchRouteFavorite(userId, routeId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Helper Functions
// ─────────────────────────────────────────────────────────────────────────────

/// Converts a [TransportRoute] to a [RouteEntity] for UI compatibility.
///
/// This is needed because the UI currently uses [RouteEntity] which has
/// a slightly different structure than the API's [TransportRoute].
RouteEntity _transportRouteToEntity(
  TransportRoute route, {
  bool isFavorite = false,
  bool isPopular = false,
}) {
  return RouteEntity(
    id: int.tryParse(route.id) ?? 0,
    name: route.name,
    startPoint: route.startPoint ?? 'Unknown',
    endPoint: route.endPoint ?? 'Unknown',
    stopsCount: 0, // Will be populated when stops are loaded
    durationMinutes: route.estimatedDuration ?? 0,
    baseFare: route.baseFare ?? 0.0,
    farePerStop: 0.0, // API doesn't have per-stop fare
    currency: route.currency?.name ?? 'KES',
    stops: [], // Will be populated when stops are loaded
    isFavorite: isFavorite,
    organizationId: route.organizationId,
    isPopular: isPopular,
  );
}
