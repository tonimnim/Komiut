import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/config/api_endpoints.dart';
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
    final queryParams = {'period': period};
    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String();
    }

    try {
      final response = await apiClient.get(
        // Assuming API Endpoint constant exists. If not, using raw string based on API Reference.
        // TODO: Update with ApiEndpoints.earningsSummary when available
        '/api/earnings/summary', 
        queryParameters: queryParams,
      );
      
      return EarningsSummaryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<EarningsModel> getTripEarnings(String tripId) async {
    try {
      final response = await apiClient.get(
        // TODO: Update with ApiEndpoints.tripEarnings when available
        '/api/earnings/trip/$tripId',
      );

      return EarningsModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
