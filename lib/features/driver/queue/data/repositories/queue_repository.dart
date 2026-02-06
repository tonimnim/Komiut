import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../domain/entities/queue_position.dart';
import '../datasources/queue_remote_datasource.dart';

/// Provider for queue repository.
final queueRepositoryProvider = Provider<QueueRepository>((ref) {
  final remoteDataSource = ref.watch(queueRemoteDataSourceProvider);
  return QueueRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Abstract interface for queue repository.
abstract class QueueRepository {
  /// Gets current queue position.
  Future<Either<Failure, QueuePosition?>> getQueuePosition(String vehicleId);

  /// Joins a queue.
  Future<Either<Failure, QueuePosition>> joinQueue({
    required String vehicleId,
    required String routeId,
  });

  /// Leaves the queue.
  Future<Either<Failure, void>> leaveQueue(String vehicleId);

  /// Gets all positions in a route queue.
  Future<Either<Failure, List<QueuePosition>>> getRouteQueue(String routeId);
}

/// Implementation of queue repository.
class QueueRepositoryImpl implements QueueRepository {
  QueueRepositoryImpl({required this.remoteDataSource});

  final QueueRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, QueuePosition?>> getQueuePosition(String vehicleId) {
    return remoteDataSource.getQueuePosition(vehicleId);
  }

  @override
  Future<Either<Failure, QueuePosition>> joinQueue({
    required String vehicleId,
    required String routeId,
  }) {
    return remoteDataSource.joinQueue(vehicleId: vehicleId, routeId: routeId);
  }

  @override
  Future<Either<Failure, void>> leaveQueue(String vehicleId) {
    return remoteDataSource.leaveQueue(vehicleId);
  }

  @override
  Future<Either<Failure, List<QueuePosition>>> getRouteQueue(String routeId) {
    return remoteDataSource.getRouteQueue(routeId);
  }
}
