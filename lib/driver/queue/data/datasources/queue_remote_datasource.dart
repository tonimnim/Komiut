import 'package:dio/dio.dart';
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
      final response = await _apiClient.get('/api/queues/$routeId/status');
      return QueueStatusModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<QueuePositionModel> joinQueue(String routeId, double lat, double lng) async {
    try {
      final response = await _apiClient.post(
        '/api/queues/$routeId/join',
        data: {'lat': lat, 'lng': lng},
      );
      return QueuePositionModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<QueuePositionModel> getQueuePosition() async {
    try {
      final response = await _apiClient.get('/api/queues/position');
      return QueuePositionModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> leaveQueue() async {
    try {
      await _apiClient.post('/api/queues/leave');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<QueuePositionModel>> getQueueList(String routeId) async {
    try {
      final response = await _apiClient.get('/api/queues/$routeId/list');
      final List list = response.data['data'];
      return list.map((item) => QueuePositionModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
