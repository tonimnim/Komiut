import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_providers.dart';
import '../../../../core/database/seed_data.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/route_entity.dart';

final routesProvider = FutureProvider<List<RouteEntity>>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  final authState = ref.watch(authStateProvider);
  final userId = authState.user?.id;

  // Seed routes if not exist
  final seeder = DatabaseSeeder(database);
  await seeder.seedRoutes();

  final dbRoutes = await database.getAllRoutes();

  // Get favorites for current user
  Set<int> favoriteIds = {};
  if (userId != null) {
    final favorites = await database.getFavoriteRoutes(userId);
    favoriteIds = favorites.map((f) => f.id).toSet();
  }

  return dbRoutes.map((dbRoute) {
    return RouteEntity.fromDatabase(
      dbRoute,
      isFavorite: favoriteIds.contains(dbRoute.id),
    );
  }).toList();
});

final routeSearchQueryProvider = StateProvider<String>((ref) => '');

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

final selectedRouteProvider = StateProvider<RouteEntity?>((ref) => null);

class BookingState {
  final int? fromStopIndex;
  final int? toStopIndex;
  final double fare;

  const BookingState({
    this.fromStopIndex,
    this.toStopIndex,
    this.fare = 0,
  });

  bool get isValid =>
      fromStopIndex != null &&
      toStopIndex != null &&
      fromStopIndex != toStopIndex;

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

final bookingStateProvider = StateNotifierProvider<BookingStateNotifier, BookingState>((ref) {
  return BookingStateNotifier(ref);
});

class BookingStateNotifier extends StateNotifier<BookingState> {
  final Ref _ref;

  BookingStateNotifier(this._ref) : super(const BookingState());

  void selectFromStop(int index) {
    state = state.copyWith(fromStopIndex: index);
    _calculateFare();
  }

  void selectToStop(int index) {
    state = state.copyWith(toStopIndex: index);
    _calculateFare();
  }

  void _calculateFare() {
    final route = _ref.read(selectedRouteProvider);
    if (route == null || state.fromStopIndex == null || state.toStopIndex == null) {
      state = state.copyWith(fare: 0);
      return;
    }

    final fare = route.calculateFare(state.fromStopIndex!, state.toStopIndex!);
    state = state.copyWith(fare: fare);
  }

  void reset() {
    state = const BookingState();
  }
}

final toggleFavoriteProvider = Provider<Future<void> Function(RouteEntity)>((ref) {
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

final routeFavoriteProvider = StreamProvider.family<bool, int>((ref, routeId) {
  final database = ref.watch(appDatabaseProvider);
  final authState = ref.watch(authStateProvider);
  final userId = authState.user?.id;

  if (userId == null) return Stream.value(false);

  return database.watchRouteFavorite(userId, routeId);
});
