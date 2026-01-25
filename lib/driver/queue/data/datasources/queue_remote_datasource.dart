import 'package:dio/dio.dart';
import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/queue_model.dart';

abstract class QueueRemoteDataSource {
  Future<QueueStatusModel> getQueueStatus(String routeId);
  Future<QueuePositionModel> joinQueue(String routeId, double lat, double lng);
  Future<QueuePositionModel> getQueuePosition();
  Future<void> leaveQueue();
  Future<List<QueuePositionModel>> getQueueList(String routeId);
}

class QueueRemoteDataSourceImpl implements QueueRemoteDataSource {
  final ApiClient _apiClient;

  QueueRemoteDataSourceImpl(this._apiClient);

  @override
  Future<QueueStatusModel> getQueueStatus(String routeId) async {
    try {
      // v2 uses GET /api/Bookings/status with routeId query param
      final response = await _apiClient.get(
        ApiEndpoints.queueStatus,
        queryParameters: {'RouteId': routeId},
      );
      final data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      return QueueStatusModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<QueuePositionModel> joinQueue(String routeId, double lat, double lng) async {
    try {
      // v2 uses POST /api/Bookings for join/booking creation
      final response = await _apiClient.post(
        ApiEndpoints.queueJoin,
        data: {
          'routeId': routeId,
          'latitude': lat,
          'longitude': lng,
        },
      );
      final data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      return QueuePositionModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<QueuePositionModel> getQueuePosition() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.queuePosition);
      final data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      return QueuePositionModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> leaveQueue() async {
    try {
      await _apiClient.post(ApiEndpoints.queueLeave);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<QueuePositionModel>> getQueueList(String routeId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.queueList,
        queryParameters: {'RouteId': routeId},
      );
      final dynamic data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      final List list = data is List ? data : (data['items'] ?? []);
      return list.map((item) => QueuePositionModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
