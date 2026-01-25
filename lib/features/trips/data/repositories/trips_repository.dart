/// Trips repository.
///
/// Provides trips data with remote-first, local-fallback pattern.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../home/data/datasources/home_local_datasource.dart';
import '../../../home/domain/entities/trip_entity.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../datasources/trips_remote_datasource.dart';

/// Provider for trips repository.
final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  final remoteDataSource = ref.watch(tripsRemoteDataSourceProvider);
  final localDataSource = ref.watch(homeLocalDataSourceProvider);
  return TripsRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

/// Abstract trips repository.
abstract class TripsRepository {
  /// Gets trips for a passenger with optional filters.
  Future<Either<Failure, List<TripEntity>>> getTrips({
    required String passengerId,
    String? status,
    int? pageNumber,
    int? pageSize,
  });

  /// Gets a single trip by ID.
  Future<Either<Failure, TripEntity>> getTripById(String id);

  /// Gets recent trips for a passenger.
  Future<Either<Failure, List<TripEntity>>> getRecentTrips(
    String passengerId, {
    int limit = 5,
  });

  /// Gets all trips for a passenger (for activity screen).
  Future<Either<Failure, List<TripEntity>>> getAllTrips(String passengerId);
}

/// Implementation of trips repository with remote-first, local-fallback.
class TripsRepositoryImpl implements TripsRepository {
  /// Creates a trips repository.
  TripsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Remote data source for API calls.
  final TripsRemoteDataSource remoteDataSource;

  /// Local data source for fallback/cache.
  final HomeLocalDataSource localDataSource;

  @override
  Future<Either<Failure, List<TripEntity>>> getTrips({
    required String passengerId,
    String? status,
    int? pageNumber,
    int? pageSize,
  }) async {
    // Try remote first
    final remoteResult = await remoteDataSource.getPassengerTrips(
      passengerId: passengerId,
      status: status,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    return remoteResult.fold(
      (failure) async {
        // On failure, try local fallback using numeric ID
        return _getLocalTripsForPassenger(passengerId);
      },
      (trips) => Right(trips),
    );
  }

  @override
  Future<Either<Failure, TripEntity>> getTripById(String id) async {
    final result = await remoteDataSource.getTripById(id);

    return result.fold(
      (failure) => Left(failure),
      (trip) => Right(trip),
    );
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getRecentTrips(
    String passengerId, {
    int limit = 5,
  }) async {
    // Try remote first
    final remoteResult = await remoteDataSource.getRecentTrips(
      passengerId,
      limit: limit,
    );

    return remoteResult.fold(
      (failure) async {
        // On failure, try local fallback
        return _getLocalRecentTrips(passengerId, limit: limit);
      },
      (trips) => Right(trips),
    );
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getAllTrips(String passengerId) async {
    // Try remote first (without pagination to get all)
    final remoteResult = await remoteDataSource.getPassengerTrips(
      passengerId: passengerId,
      pageSize: 100, // Get a large number for "all" trips
    );

    return remoteResult.fold(
      (failure) async {
        // On failure, try local fallback
        return _getLocalTripsForPassenger(passengerId);
      },
      (trips) => Right(trips),
    );
  }

  /// Gets trips from local database for fallback.
  Future<Either<Failure, List<TripEntity>>> _getLocalTripsForPassenger(
    String passengerId,
  ) async {
    try {
      // Convert string ID to int for local database compatibility
      final numericId = int.tryParse(passengerId) ?? passengerId.hashCode.abs();
      final trips = await localDataSource.getAllTrips(numericId);
      return Right(trips);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to get local trips: $e'));
    }
  }

  /// Gets recent trips from local database for fallback.
  Future<Either<Failure, List<TripEntity>>> _getLocalRecentTrips(
    String passengerId, {
    int limit = 5,
  }) async {
    try {
      // Convert string ID to int for local database compatibility
      final numericId = int.tryParse(passengerId) ?? passengerId.hashCode.abs();
      final trips = await localDataSource.getRecentTrips(numericId, limit: limit);
      return Right(trips);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to get local recent trips: $e'));
    }
  }
}
