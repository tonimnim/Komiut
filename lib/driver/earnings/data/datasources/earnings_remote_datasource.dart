import 'package:dio/dio.dart';
import '../../../../core/config/api_endpoints.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/earnings_model.dart';
import '../models/earnings_summary_model.dart';

abstract class EarningsRemoteDataSource {
  Future<EarningsSummaryModel> getEarningsSummary({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<EarningsModel> getTripEarnings(String tripId);
}

class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  final ApiClient apiClient;

  EarningsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<EarningsSummaryModel> getEarningsSummary({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) {
      queryParams['FromDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['ToDate'] = endDate.toIso8601String();
    }

    try {
      final response = await apiClient.getDriver(
        ApiEndpoints.earningsSummary, 
        queryParameters: queryParams,
      );
      
      final data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      final result = data is List ? data.first : data;
      return EarningsSummaryModel.fromJson(result as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<EarningsModel> getTripEarnings(String tripId) async {
    try {
      final response = await apiClient.getDriver(
        ApiEndpoints.earningsTrip(tripId),
      );

      final data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      return EarningsModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
