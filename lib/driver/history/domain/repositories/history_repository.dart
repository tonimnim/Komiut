import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/trip_history.dart';
import '../entities/trip_history_details.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<TripHistory>>> getTripHistory({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? routeId,
  });

  Future<Either<Failure, TripHistoryDetails>> getTripHistoryDetails(String tripId);
}
