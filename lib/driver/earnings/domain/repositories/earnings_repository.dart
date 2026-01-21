import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/earnings.dart';
import '../entities/earnings_summary.dart';

abstract class EarningsRepository {
  Future<Either<Failure, EarningsSummary>> getEarningsSummary({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, Earnings>> getTripEarnings(String tripId);
}
