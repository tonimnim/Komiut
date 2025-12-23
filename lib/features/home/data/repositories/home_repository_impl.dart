import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource _localDataSource;

  HomeRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, WalletEntity>> getWallet(int userId) async {
    try {
      final wallet = await _localDataSource.getWallet(userId);
      return Right(wallet);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getRecentTrips(int userId, {int limit = 5}) async {
    try {
      final trips = await _localDataSource.getRecentTrips(userId, limit: limit);
      return Right(trips);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getAllTrips(int userId) async {
    try {
      final trips = await _localDataSource.getAllTrips(userId);
      return Right(trips);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<WalletEntity?> watchWallet(int userId) {
    return _localDataSource.watchWallet(userId);
  }

  @override
  Stream<List<TripEntity>> watchTrips(int userId) {
    return _localDataSource.watchTrips(userId);
  }
}
