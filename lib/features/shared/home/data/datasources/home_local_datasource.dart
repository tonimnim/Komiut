import '../../../../../core/database/app_database.dart';
import '../../../../../core/errors/exceptions.dart';
import '../models/wallet_model.dart';
import '../models/trip_model.dart';

abstract class HomeLocalDataSource {
  Future<WalletModel> getWallet(int userId);
  Future<List<TripModel>> getRecentTrips(int userId, {int limit});
  Future<List<TripModel>> getAllTrips(int userId);
  Stream<WalletModel?> watchWallet(int userId);
  Stream<List<TripModel>> watchTrips(int userId);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final AppDatabase _database;

  HomeLocalDataSourceImpl(this._database);

  @override
  Future<WalletModel> getWallet(int userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final wallet = await _database.getWalletByUserId(userId);
      if (wallet == null) {
        throw const CacheException('Wallet not found');
      }
      return WalletModel.fromDatabase(wallet);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to get wallet: $e');
    }
  }

  @override
  Future<List<TripModel>> getRecentTrips(int userId, {int limit = 5}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final trips = await _database.getRecentTrips(userId, limit: limit);
      return trips.map((t) => TripModel.fromDatabase(t)).toList();
    } catch (e) {
      throw CacheException('Failed to get trips: $e');
    }
  }

  @override
  Future<List<TripModel>> getAllTrips(int userId) async {
    try {
      final trips = await _database.getTripsByUserId(userId);
      return trips.map((t) => TripModel.fromDatabase(t)).toList();
    } catch (e) {
      throw CacheException('Failed to get trips: $e');
    }
  }

  @override
  Stream<WalletModel?> watchWallet(int userId) {
    return _database.watchWalletByUserId(userId).map(
          (wallet) => wallet != null ? WalletModel.fromDatabase(wallet) : null,
        );
  }

  @override
  Stream<List<TripModel>> watchTrips(int userId) {
    return _database.watchTripsByUserId(userId).map(
          (trips) => trips.map((t) => TripModel.fromDatabase(t)).toList(),
        );
  }
}
