import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/queue_entities.dart';

abstract class QueueRepository {
  Future<Either<Failure, QueueStatus>> getQueueStatus(String routeId);
  Future<Either<Failure, QueuePosition>> joinQueue(String routeId, double lat, double lng);
  Future<Either<Failure, QueuePosition>> getQueuePosition();
  Future<Either<Failure, Unit>> leaveQueue();
  Future<Either<Failure, List<QueuePosition>>> getQueueList(String routeId);
}
