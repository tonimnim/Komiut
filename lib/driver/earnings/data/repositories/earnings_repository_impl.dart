import 'package:dartz/dartz.dart';

import 'package:komiut/core/errors/failures.dart';
import 'package:komiut/core/network/api_exceptions.dart';
import 'package:komiut/driver/earnings/domain/entities/earnings.dart';
import 'package:komiut/driver/earnings/domain/entities/earnings_summary.dart';
import 'package:komiut/driver/earnings/domain/repositories/earnings_repository.dart';
import '../datasources/earnings_remote_datasource.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  final EarningsRemoteDataSource remoteDataSource;

  EarningsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, EarningsSummary>> getEarningsSummary({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final summary = await remoteDataSource.getEarningsSummary(
        period: period,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(summary);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Earnings>> getTripEarnings(String tripId) async {
    try {
      final earnings = await remoteDataSource.getTripEarnings(tripId);
      return Right(earnings);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
