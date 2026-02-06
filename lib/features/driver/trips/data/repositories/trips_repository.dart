import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../domain/entities/driver_trip.dart';
import '../datasources/trips_remote_datasource.dart';

/// Provider for trips repository.
final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  final remoteDataSource = ref.watch(tripsRemoteDataSourceProvider);
  return TripsRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Abstract interface for trips repository.
abstract class TripsRepository {
  /// Gets trips.
  Future<Either<Failure, List<DriverTrip>>> getTrips({
    String? vehicleId,
    String? routeId,
    DriverTripStatus? status,
    int? pageNumber,
    int? pageSize,
  });

  /// Gets active trip.
  Future<Either<Failure, DriverTrip?>> getActiveTrip(String vehicleId);

  /// Starts a trip.
  Future<Either<Failure, DriverTrip>> startTrip({
    required String vehicleId,
    required String routeId,
    required String driverId,
    String? toutId,
  });

  /// Ends a trip.
  Future<Either<Failure, void>> endTrip({
    required String tripId,
    String? reason,
  });

  /// Updates trip status.
  Future<Either<Failure, void>> updateTripStatus({
    required String tripId,
    required DriverTripStatus status,
    String? reason,
  });
}

/// Implementation of trips repository.
class TripsRepositoryImpl implements TripsRepository {
  TripsRepositoryImpl({required this.remoteDataSource});

  final TripsRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<DriverTrip>>> getTrips({
    String? vehicleId,
    String? routeId,
    DriverTripStatus? status,
    int? pageNumber,
    int? pageSize,
  }) {
    return remoteDataSource.getTrips(
      vehicleId: vehicleId,
      routeId: routeId,
      status: status,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  @override
  Future<Either<Failure, DriverTrip?>> getActiveTrip(String vehicleId) {
    return remoteDataSource.getActiveTrip(vehicleId);
  }

  @override
  Future<Either<Failure, DriverTrip>> startTrip({
    required String vehicleId,
    required String routeId,
    required String driverId,
    String? toutId,
  }) {
    return remoteDataSource.startTrip(
      vehicleId: vehicleId,
      routeId: routeId,
      driverId: driverId,
      toutId: toutId,
    );
  }

  @override
  Future<Either<Failure, void>> endTrip({
    required String tripId,
    String? reason,
  }) {
    return remoteDataSource.endTrip(tripId: tripId, reason: reason);
  }

  @override
  Future<Either<Failure, void>> updateTripStatus({
    required String tripId,
    required DriverTripStatus status,
    String? reason,
  }) {
    return remoteDataSource.updateTripStatus(
      tripId: tripId,
      status: status,
      reason: reason,
    );
  }
}
