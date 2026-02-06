import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/earnings_summary.dart';
import '../../domain/entities/earnings_transaction.dart';
import '../models/earnings_summary_model.dart';
import '../models/earnings_transaction_model.dart';

/// Provider for earnings remote data source.
final earningsRemoteDataSourceProvider =
    Provider<EarningsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EarningsRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract interface for earnings data operations.
abstract class EarningsRemoteDataSource {
  /// Fetches earnings summary for a vehicle.
  Future<Either<Failure, EarningsSummary>> getEarningsSummary(String vehicleId);

  /// Fetches earnings transaction history.
  Future<Either<Failure, List<EarningsTransaction>>> getEarningsHistory({
    required String vehicleId,
    DateTime? fromDate,
    DateTime? toDate,
    int? pageNumber,
    int? pageSize,
  });
}

/// Implementation of earnings remote data source.
class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  EarningsRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Either<Failure, EarningsSummary>> getEarningsSummary(
      String vehicleId) async {
    return apiClient.get<EarningsSummary>(
      ApiEndpoints.dailyVehicleTotals,
      queryParameters: {'VehicleId': vehicleId},
      fromJson: (data) {
        if (data is List) {
          return EarningsSummaryModel.fromDailyTotals(data).toEntity();
        }
        return EarningsSummaryModel.fromJson(
          data as Map<String, dynamic>,
        ).toEntity();
      },
    );
  }

  @override
  Future<Either<Failure, List<EarningsTransaction>>> getEarningsHistory({
    required String vehicleId,
    DateTime? fromDate,
    DateTime? toDate,
    int? pageNumber,
    int? pageSize,
  }) async {
    return apiClient.get<List<EarningsTransaction>>(
      ApiEndpoints.payments,
      queryParameters: {
        'VehicleId': vehicleId,
        if (pageNumber != null) 'PageNumber': pageNumber.toString(),
        if (pageSize != null) 'PageSize': pageSize.toString(),
      },
      fromJson: (data) {
        if (data is List) {
          return data
              .map((json) => EarningsTransactionModel.fromJson(
                    json as Map<String, dynamic>,
                  ).toEntity())
              .toList();
        }
        return <EarningsTransaction>[];
      },
    );
  }
}
