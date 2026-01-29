import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/wallet_entity.dart';
import '../entities/trip_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, WalletEntity>> getWallet(int userId);
  Future<Either<Failure, List<TripEntity>>> getRecentTrips(int userId, {int limit});
  Future<Either<Failure, List<TripEntity>>> getAllTrips(int userId);
  Stream<WalletEntity?> watchWallet(int userId);
  Stream<List<TripEntity>> watchTrips(int userId);
}
