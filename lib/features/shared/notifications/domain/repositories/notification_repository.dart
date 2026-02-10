import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, NotificationEntity>> getNotification(String id);

  Future<Either<Failure, void>> markAsRead(String id);

  Future<Either<Failure, void>> markAllAsRead();
}
