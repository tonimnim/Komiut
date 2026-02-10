import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/network_info.dart';
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
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    final result = await _remoteDataSource.getNotifications(
      pageNumber: pageNumber,
      pageSize: pageSize,
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
    // API doesn't support this yet — handled locally in the notifier
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    // API doesn't support this yet — handled locally in the notifier
    return const Right(null);
  }
}
