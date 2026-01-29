import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
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
      final response = await _apiClient.getDriver(
        ApiEndpoints.queueByRoute(routeId),
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
      final response = await _apiClient.postDriver(
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
      final response = await _apiClient.getDriver(
        ApiEndpoints.queueMyPosition,
      );
      final data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      return QueuePositionModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> leaveQueue() async {
    try {
      await _apiClient.postDriver(
        ApiEndpoints.queueLeave,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<QueuePositionModel>> getQueueList(String routeId) async {
    try {
      final response = await _apiClient.getDriver(
        ApiEndpoints.queueByRoute(routeId),
      );
      final dynamic data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      final List list = data is List ? data : (data['items'] ?? []);
      return list.map((item) => QueuePositionModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
