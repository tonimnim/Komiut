import 'package:dartz/dartz.dart';
import 'package:komiut_app/core/errors/failures.dart';
import 'package:komiut_app/core/network/api_exceptions.dart';
import 'package:komiut_app/driver/queue/domain/entities/queue_entities.dart';
import 'package:komiut_app/driver/queue/domain/repositories/queue_repository.dart';
import '../datasources/queue_remote_datasource.dart';

class QueueRepositoryImpl implements QueueRepository {
  final QueueRemoteDataSource remoteDataSource;

  QueueRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, QueueStatus>> getQueueStatus(String routeId) async {
    try {
      final status = await remoteDataSource.getQueueStatus(routeId);
      return Right(status);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QueuePosition>> joinQueue(String routeId, double lat, double lng) async {
    try {
      final position = await remoteDataSource.joinQueue(routeId, lat, lng);
      return Right(position);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QueuePosition>> getQueuePosition() async {
    try {
      final position = await remoteDataSource.getQueuePosition();
      return Right(position);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> leaveQueue() async {
    try {
      await remoteDataSource.leaveQueue();
      return const Right(unit);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QueuePosition>>> getQueueList(String routeId) async {
    try {
      final list = await remoteDataSource.getQueueList(routeId);
      return Right(list);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
