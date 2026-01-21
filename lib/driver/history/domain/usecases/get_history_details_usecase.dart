import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/trip_history_details.dart';
import '../repositories/history_repository.dart';

class GetTripHistoryDetailsUseCase {
  final HistoryRepository repository;

  GetTripHistoryDetailsUseCase(this.repository);

  Future<Either<Failure, TripHistoryDetails>> call(String tripId) async {
    return await repository.getTripHistoryDetails(tripId);
  }
}
