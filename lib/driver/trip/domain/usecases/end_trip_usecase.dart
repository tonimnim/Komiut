import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class EndTripUseCase {
  final TripRepository repository;

  EndTripUseCase(this.repository);

  Future<Either<Failure, Trip>> call(EndTripParams params) async {
    return await repository.endTrip(
      params.tripId,
      finalPassengers: params.finalPassengers, 
      finalEarnings: params.finalEarnings,
    );
  }
}

class EndTripParams extends Equatable {
  final String tripId;
  final int finalPassengers;
  final double finalEarnings;

  const EndTripParams({
    required this.tripId,
    required this.finalPassengers,
    required this.finalEarnings,
  });

  @override
  List<Object?> get props => [tripId, finalPassengers, finalEarnings];
}
