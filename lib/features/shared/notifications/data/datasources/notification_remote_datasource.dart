import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../models/notification_model.dart';

/// Provider for notification remote datasource.
final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationRemoteDataSourceImpl(apiClient);
});

abstract class NotificationRemoteDataSource {
  Future<Either<Failure, List<NotificationModel>>> getNotifications({
    int pageNumber = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, NotificationModel>> getNotification(String id);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSourceImpl(this._apiClient);

  /// Extracts the items list from the backend's paginated envelope.
  /// Handles: raw List, {"message": {"items": [...]}}, {"items": [...]}, etc.
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

  /// Unwraps the backend's {"message": {...}} envelope for single objects.
  Map<String, dynamic> _unwrapMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['message'];
      if (inner is Map<String, dynamic>) return inner;
      return data;
    }
    return {};
  }

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    return _apiClient.get<List<NotificationModel>>(
      ApiEndpoints.notifications,
      queryParameters: {
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      },
      fromJson: (data) {
        final items = _extractItems(data);
        return items
            .map((json) =>
                NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  @override
  Future<Either<Failure, NotificationModel>> getNotification(String id) async {
    return _apiClient.get<NotificationModel>(
      ApiEndpoints.notificationById(id),
      fromJson: (data) {
        final json = _unwrapMessage(data);
        return NotificationModel.fromJson(json);
      },
    );
  }
}
