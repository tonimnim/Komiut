import 'package:dio/dio.dart';

import 'package:komiut_app/core/network/api_client.dart';
import 'package:komiut_app/core/network/api_exceptions.dart';
import 'package:komiut_app/driver/history/data/models/trip_history_model.dart';
import 'package:komiut_app/driver/history/domain/entities/trip_history_details.dart';
// Note: We might need a Model for TripHistoryDetails too if serialization logic is complex, 
// but for now assuming we can map it or create a model if needed. 
// For strict clean architecture, let's assume we'll parse it manually here or add a model later.

abstract class HistoryRemoteDataSource {
  Future<List<TripHistoryModel>> getTripHistory({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? routeId,
  });

  Future<dynamic> getTripHistoryDetails(String tripId); // Returns raw JSON or Model
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
      'page': page,
      'limit': limit,
    };
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
    if (routeId != null) queryParams['route_id'] = routeId;

    try {
      final response = await apiClient.get(
        '/api/trips/history',
        queryParameters: queryParams,
      );
      
      final List data = response.data['data']['trips'];
      return data.map((e) => TripHistoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<dynamic> getTripHistoryDetails(String tripId) async {
    try {
      final response = await apiClient.get('/api/trips/$tripId');
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
