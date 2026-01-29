import 'package:dio/dio.dart';
import 'package:komiut/core/config/api_endpoints.dart';

import 'package:komiut/core/network/api_client.dart';
import 'package:komiut/core/network/api_exceptions.dart';
import 'package:komiut/driver/history/data/models/trip_history_model.dart';


abstract class HistoryRemoteDataSource {
  Future<List<TripHistoryModel>> getTripHistory({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? routeId,
  });

  Future<dynamic> getTripHistoryDetails(String tripId);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final ApiClient apiClient;

  HistoryRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<TripHistoryModel>> getTripHistory({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? routeId,
  }) async {
    final Map<String, dynamic> queryParams = {
      'PageNumber': page,
      'PageSize': limit,
    };
    if (startDate != null) queryParams['FromDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['ToDate'] = endDate.toIso8601String();
    if (routeId != null) queryParams['RouteId'] = routeId;

    try {
      final response = await apiClient.getDriver(
        ApiEndpoints.tripHistory,
        queryParameters: queryParams,
      );
      
      final dynamic data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      final List list = data is List ? data : (data['items'] ?? []);
      return list.map((e) => TripHistoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<dynamic> getTripHistoryDetails(String tripId) async {
    try {
      final response = await apiClient.getDriver(ApiEndpoints.tripDetails(tripId));
      final data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      return data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
