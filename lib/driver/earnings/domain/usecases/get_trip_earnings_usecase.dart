import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/earnings.dart';
import '../repositories/earnings_repository.dart';

class GetTripEarningsUseCase {
  final EarningsRepository repository;

  GetTripEarningsUseCase(this.repository);

  Future<Either<Failure, Earnings>> call(String tripId) async {
    return await repository.getTripEarnings(tripId);
  }
}
