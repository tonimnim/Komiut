/// Home feature providers.
///
/// Provides all home-related state management and dependencies.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/database_providers.dart';
import '../../data/datasources/home_local_datasource.dart';
import '../../data/datasources/wallet_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/entities/trip_entity.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../passenger/trips/data/repositories/trips_repository.dart';

/// Provider for the home local datasource.
final homeLocalDataSourceProvider = Provider<HomeLocalDataSource>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return HomeLocalDataSourceImpl(database);
});

// Note: walletRemoteDataSourceProvider is defined in wallet_remote_datasource.dart
// and is imported above. We use it directly in walletProvider.

/// Provider for the home repository.
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final dataSource = ref.watch(homeLocalDataSourceProvider);
  return HomeRepositoryImpl(dataSource);
});

/// Provider for the user's wallet.
///
/// Attempts to fetch wallet from API first, falls back to local on failure.
final walletProvider = FutureProvider<WalletEntity?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final localRepository = ref.watch(homeRepositoryProvider);

  if (authState.user == null) return null;

  // Try remote first
  try {
    final remoteDataSource = ref.watch(walletRemoteDataSourceProvider);
    final remoteResult =
        await remoteDataSource.getWalletBalance(authState.user!.id.toString());

    return remoteResult.fold(
      (failure) async {
        // On API failure, fall back to local
        final localResult = await localRepository.getWallet(authState.user!.id);
        return localResult.fold(
          (failure) => null,
          (wallet) => wallet,
        );
      },
      (wallet) => wallet,
    );
  } catch (e) {
    // On any error, fall back to local
    final localResult = await localRepository.getWallet(authState.user!.id);
    return localResult.fold(
      (failure) => null,
      (wallet) => wallet,
    );
  }
});

/// Provider for the user's wallet (local-only variant).
///
/// Use this when you want to bypass the remote API and use only local data.
final walletLocalOnlyProvider = FutureProvider<WalletEntity?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(homeRepositoryProvider);

  if (authState.user == null) return null;

  final result = await repository.getWallet(authState.user!.id);
  return result.fold(
    (failure) => null,
    (wallet) => wallet,
  );
});

/// Recent trips provider - uses remote API with local fallback.
///
/// Fetches the 5 most recent trips for the current user.
/// Falls back to local database if API call fails.
final recentTripsProvider = FutureProvider<List<TripEntity>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final tripsRepository = ref.watch(tripsRepositoryProvider);

  if (authState.user == null) return [];

  // Use new trips repository (remote-first, local-fallback)
  final result = await tripsRepository.getRecentTrips(
    authState.user!.id.toString(),
    limit: 5,
  );

  return result.fold(
    (failure) => [],
    (trips) => trips,
  );
});

/// All trips provider - uses remote API with local fallback.
///
/// Fetches all trips for the current user (for activity/history screen).
/// Falls back to local database if API call fails.
final allTripsProvider = FutureProvider<List<TripEntity>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final tripsRepository = ref.watch(tripsRepositoryProvider);

  if (authState.user == null) return [];

  // Use new trips repository (remote-first, local-fallback)
  final result =
      await tripsRepository.getAllTrips(authState.user!.id.toString());

  return result.fold(
    (failure) => [],
    (trips) => trips,
  );
});

/// Provider for watching wallet changes (local database only).
///
/// Use this for real-time updates from the local database.
final walletStreamProvider = StreamProvider<WalletEntity?>((ref) {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(homeRepositoryProvider);

  if (authState.user == null) {
    return Stream.value(null);
  }

  return repository.watchWallet(authState.user!.id);
});

/// Provider for refreshing wallet from the API.
///
/// Call this to force a refresh of wallet data from the server.
final refreshWalletProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    // Invalidate the wallet provider to trigger a refresh
    ref.invalidate(walletProvider);
  };
});
