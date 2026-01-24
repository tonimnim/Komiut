import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int? page,
    int? limit,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    final result = await _remoteDataSource.getNotifications(
      page: page,
      limit: limit,
    );

    return result.fold(
      (failure) => Left(failure),
      (notifications) => Right(notifications.cast<NotificationEntity>()),
    );
  }

  @override
  Future<Either<Failure, NotificationEntity>> getNotification(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    final result = await _remoteDataSource.getNotification(id);

    return result.fold(
      (failure) => Left(failure),
      (notification) => Right(notification),
    );
  }

  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    return _remoteDataSource.markAsRead(id);
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    return _remoteDataSource.markAllAsRead();
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    return _remoteDataSource.deleteNotification(id);
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    return _remoteDataSource.getUnreadCount();
  }
}
