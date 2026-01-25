import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/trip_history.dart';
import '../repositories/history_repository.dart';

class GetTripHistoryUseCase {
  final HistoryRepository repository;

  GetTripHistoryUseCase(this.repository);

  Future<Either<Failure, List<TripHistory>>> call({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? routeId,
  }) async {
    return await repository.getTripHistory(
      page: page,
      limit: limit,
      startDate: startDate,
      endDate: endDate,
      routeId: routeId,
    );
  }
}
