import 'package:dartz/dartz.dart';

import 'package:komiut/core/errors/failures.dart';
import 'package:komiut/core/network/api_exceptions.dart';
import 'package:komiut/driver/trip/domain/entities/trip.dart';
import 'package:komiut/driver/trip/domain/repositories/trip_repository.dart';
import 'package:komiut/driver/trip/data/datasources/trip_remote_datasource.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Trip>> startTrip(String routeId, String vehicleId) async {
    try {
      final trip = await remoteDataSource.startTrip(routeId, vehicleId);
      return Right(trip);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Trip>> updateTripStatus(String tripId, TripStatus status, {Map<String, dynamic>? data}) async {
    try {
      String statusStr;
      switch (status) {
        case TripStatus.scheduled: statusStr = 'scheduled'; break;
        case TripStatus.started: statusStr = 'started'; break;
        case TripStatus.inProgress: statusStr = 'in_progress'; break;
        case TripStatus.completed: statusStr = 'completed'; break;
        case TripStatus.cancelled: statusStr = 'cancelled'; break;
      }
      
      final trip = await remoteDataSource.updateTripStatus(tripId, statusStr, data: data);
      return Right(trip);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Trip>> endTrip(String tripId, {required int finalPassengers, required double finalEarnings}) async {
    try {
      final trip = await remoteDataSource.endTrip(tripId, finalPassengers: finalPassengers, finalEarnings: finalEarnings);
      return Right(trip);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Trip>> getActiveTrip() async {
    try {
      final trip = await remoteDataSource.getActiveTrip();
      if (trip == null) {
        return const Left(CacheFailure("No active trip found"));
      }
      return Right(trip);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Trip>> getTripById(String tripId) async {
    try {
      final trip = await remoteDataSource.getTripById(tripId);
      return Right(trip);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
