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
  Future<Either<Failure, EarningsSummary>> getEarningsSummary(String vehicleId);
  Future<Either<Failure, List<EarningsTransaction>>> getEarningsHistory({
    required String vehicleId,
    DateTime? fromDate,
    DateTime? toDate,
    int pageNumber = 1,
    int pageSize = 20,
  });
}

/// Implementation of earnings remote data source.
class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  EarningsRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  List<dynamic> _extractItems(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final inner = data['message'];
      if (inner is Map<String, dynamic> && inner['items'] is List) {
        return inner['items'] as List;
      }
      if (data['items'] is List) {
        return data['items'] as List;
      }
    }
    return [];
  }

  Map<String, dynamic> _unwrapMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['message'];
      if (inner is Map<String, dynamic>) return inner;
      return data;
    }
    return {};
  }

  @override
  Future<Either<Failure, EarningsSummary>> getEarningsSummary(
      String vehicleId) async {
    return apiClient.get<EarningsSummary>(
      ApiEndpoints.dailyVehicleTotals,
      queryParameters: {
        'VehicleId': vehicleId,
        'PageNumber': 1,
        'PageSize': 100,
      },
      fromJson: (data) {
        final items = _extractItems(data);
        if (items.isNotEmpty) {
          return EarningsSummaryModel.fromDailyTotals(items).toEntity();
        }
        // Fallback: try parsing as a single summary object
        final json = _unwrapMessage(data);
        return EarningsSummaryModel.fromJson(json).toEntity();
      },
    );
  }

  @override
  Future<Either<Failure, List<EarningsTransaction>>> getEarningsHistory({
    required String vehicleId,
    DateTime? fromDate,
    DateTime? toDate,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    return apiClient.get<List<EarningsTransaction>>(
      ApiEndpoints.payments,
      queryParameters: {
        'VehicleId': vehicleId,
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      },
      fromJson: (data) {
        final items = _extractItems(data);
        return items
            .map((json) => EarningsTransactionModel.fromJson(
                  json as Map<String, dynamic>,
                ).toEntity())
            .toList();
      },
    );
  }
}
