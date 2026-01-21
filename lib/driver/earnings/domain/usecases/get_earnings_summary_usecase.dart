import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/earnings_summary.dart';
import '../repositories/earnings_repository.dart';

class GetEarningsSummaryUseCase {
  final EarningsRepository repository;

  GetEarningsSummaryUseCase(this.repository);

  Future<Either<Failure, EarningsSummary>> call(GetEarningsSummaryParams params) async {
    return await repository.getEarningsSummary(
      period: params.period,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetEarningsSummaryParams extends Equatable {
  final String period;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetEarningsSummaryParams({
    required this.period,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [period, startDate, endDate];
}
