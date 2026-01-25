import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/trip.dart';

abstract class TripRepository {
  Future<Either<Failure, Trip>> startTrip(String routeId, String vehicleId);
  Future<Either<Failure, Trip>> updateTripStatus(String tripId, TripStatus status, {Map<String, dynamic>? data});
  Future<Either<Failure, Trip>> endTrip(String tripId, {required int finalPassengers, required double finalEarnings});
  Future<Either<Failure, Trip>> getActiveTrip();
  Future<Either<Failure, Trip>> getTripById(String tripId);
}
