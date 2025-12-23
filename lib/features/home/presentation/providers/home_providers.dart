import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_providers.dart';
import '../../data/datasources/home_local_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/entities/trip_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final homeLocalDataSourceProvider = Provider<HomeLocalDataSource>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return HomeLocalDataSourceImpl(database);
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final dataSource = ref.watch(homeLocalDataSourceProvider);
  return HomeRepositoryImpl(dataSource);
});

final walletProvider = FutureProvider<WalletEntity?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(homeRepositoryProvider);

  if (authState.user == null) return null;

  final result = await repository.getWallet(authState.user!.id);
  return result.fold(
    (failure) => null,
    (wallet) => wallet,
  );
});

final recentTripsProvider = FutureProvider<List<TripEntity>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(homeRepositoryProvider);

  if (authState.user == null) return [];

  final result = await repository.getRecentTrips(authState.user!.id, limit: 5);
  return result.fold(
    (failure) => [],
    (trips) => trips,
  );
});

final allTripsProvider = FutureProvider<List<TripEntity>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(homeRepositoryProvider);

  if (authState.user == null) return [];

  final result = await repository.getAllTrips(authState.user!.id);
  return result.fold(
    (failure) => [],
    (trips) => trips,
  );
});
