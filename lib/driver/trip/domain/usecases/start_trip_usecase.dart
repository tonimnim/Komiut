import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class StartTripUseCase {
  final TripRepository repository;

  StartTripUseCase(this.repository);

  Future<Either<Failure, Trip>> call(StartTripParams params) async {
    return await repository.startTrip(params.routeId, params.vehicleId);
  }
}

class StartTripParams extends Equatable {
  final String routeId;
  final String vehicleId;

  const StartTripParams({required this.routeId, required this.vehicleId});

  @override
  List<Object?> get props => [routeId, vehicleId];
}
