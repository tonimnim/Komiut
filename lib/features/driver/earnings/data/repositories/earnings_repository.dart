import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../domain/entities/earnings_summary.dart';
import '../../domain/entities/earnings_transaction.dart';
import '../datasources/earnings_remote_datasource.dart';

/// Provider for earnings repository.
final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  final remoteDataSource = ref.watch(earningsRemoteDataSourceProvider);
  return EarningsRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Abstract interface for earnings repository.
abstract class EarningsRepository {
  /// Gets earnings summary.
  Future<Either<Failure, EarningsSummary>> getEarningsSummary(String vehicleId);

  /// Gets earnings transaction history.
  Future<Either<Failure, List<EarningsTransaction>>> getEarningsHistory({
    required String vehicleId,
    DateTime? fromDate,
    DateTime? toDate,
    int pageNumber = 1,
    int pageSize = 20,
  });
}

/// Implementation of earnings repository.
class EarningsRepositoryImpl implements EarningsRepository {
  EarningsRepositoryImpl({required this.remoteDataSource});

  final EarningsRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, EarningsSummary>> getEarningsSummary(
      String vehicleId) {
    return remoteDataSource.getEarningsSummary(vehicleId);
  }

  @override
  Future<Either<Failure, List<EarningsTransaction>>> getEarningsHistory({
    required String vehicleId,
    DateTime? fromDate,
    DateTime? toDate,
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    return remoteDataSource.getEarningsHistory(
      vehicleId: vehicleId,
      fromDate: fromDate,
      toDate: toDate,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
