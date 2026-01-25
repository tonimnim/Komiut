import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<Either<Failure, List<NotificationModel>>> getNotifications({int? page, int? limit});
  Future<Either<Failure, NotificationModel>> getNotification(String id);
  Future<Either<Failure, void>> markAsRead(String id);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> deleteNotification(String id);
  Future<Either<Failure, int>> getUnreadCount();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications({
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final result = await _apiClient.get(
      '/notifications',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        final List<dynamic> items = data['data'] ?? data ?? [];
        return Right(items.map((json) => NotificationModel.fromJson(json)).toList());
      },
    );
  }

  @override
  Future<Either<Failure, NotificationModel>> getNotification(String id) async {
    final result = await _apiClient.get('/notifications/$id');

    return result.fold(
      (failure) => Left(failure),
      (data) => Right(NotificationModel.fromJson(data['data'] ?? data)),
    );
  }

  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    final result = await _apiClient.patch('/notifications/$id/read');
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    final result = await _apiClient.patch('/notifications/read-all');
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String id) async {
    final result = await _apiClient.delete('/notifications/$id');
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    final result = await _apiClient.get('/notifications/unread-count');
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data['count'] as int? ?? 0),
    );
  }
}
