import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/queue_position.dart';
import '../models/queue_position_model.dart';

/// Provider for queue remote data source.
final queueRemoteDataSourceProvider = Provider<QueueRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QueueRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract interface for queue data operations.
abstract class QueueRemoteDataSource {
  /// Gets current queue position for a vehicle.
  Future<Either<Failure, QueuePosition?>> getQueuePosition(String vehicleId);

  /// Joins a queue for a route.
  Future<Either<Failure, QueuePosition>> joinQueue({
    required String vehicleId,
    required String routeId,
  });

  /// Leaves the current queue.
  Future<Either<Failure, void>> leaveQueue(String vehicleId);

  /// Gets all vehicles in queue for a route.
  Future<Either<Failure, List<QueuePosition>>> getRouteQueue(String routeId);
}

/// Implementation of queue remote data source.
class QueueRemoteDataSourceImpl implements QueueRemoteDataSource {
  QueueRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Either<Failure, QueuePosition?>> getQueuePosition(
      String vehicleId) async {
    // Get vehicle with current route
    final vehicleResult = await apiClient.get<Map<String, dynamic>?>(
      ApiEndpoints.vehicles,
      queryParameters: {'VehicleId': vehicleId},
      fromJson: (data) {
        if (data is List && data.isNotEmpty) {
          return data.first as Map<String, dynamic>;
        }
        return null;
      },
    );

    return vehicleResult.fold(
      (failure) => Left(failure),
      (vehicle) async {
        if (vehicle == null || vehicle['currentRouteId'] == null) {
          return const Right(null);
        }

        // Get route info
        final routeResult = await apiClient.get<Map<String, dynamic>?>(
          ApiEndpoints.routes,
          queryParameters: {'RouteId': vehicle['currentRouteId']},
          fromJson: (data) {
            if (data is List && data.isNotEmpty) {
              return data.first as Map<String, dynamic>;
            }
            return null;
          },
        );

        return routeResult.fold(
          (failure) => Left(failure),
          (route) {
            if (route == null) return const Right(null);

            // Create queue position from vehicle/route data
            final model = QueuePositionModel.fromVehicleAssignment(
              vehicle,
              route,
              1, // Position would come from real queue system
            );
            return Right(model.toEntity());
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, QueuePosition>> joinQueue({
    required String vehicleId,
    required String routeId,
  }) async {
    // Assign route to vehicle
    final result = await apiClient.post<void>(
      ApiEndpoints.assignRoute,
      data: {
        'vehicleId': vehicleId,
        'routeId': routeId,
      },
    );

    return result.fold(
      (failure) => Left(failure),
      (_) async {
        // Fetch the new queue position
        final positionResult = await getQueuePosition(vehicleId);
        return positionResult.fold(
          (failure) => Left(failure),
          (position) {
            if (position == null) {
              return const Left(ServerFailure('Failed to get queue position'));
            }
            return Right(position);
          },
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> leaveQueue(String vehicleId) async {
    // Remove route assignment
    return apiClient.put<void>(
      ApiEndpoints.vehicles,
      data: {
        'vehicleId': vehicleId,
        'currentRouteId': null,
      },
    );
  }

  @override
  Future<Either<Failure, List<QueuePosition>>> getRouteQueue(
      String routeId) async {
    return apiClient.get<List<QueuePosition>>(
      ApiEndpoints.vehicles,
      queryParameters: {'RouteId': routeId},
      fromJson: (data) {
        if (data is! List) return <QueuePosition>[];

        final positions = <QueuePosition>[];
        for (var i = 0; i < data.length; i++) {
          final vehicle = data[i] as Map<String, dynamic>;
          if (vehicle['currentRouteId']?.toString() == routeId) {
            final model = QueuePositionModel(
              id: vehicle['id']?.toString() ?? '',
              position: i + 1,
              routeId: routeId,
              routeName: '', // Would need to fetch
              joinedAt: DateTime.now(),
              vehicleRegistration: (vehicle['registrationNumber']
                  as Map<String, dynamic>?)?['value'] as String?,
            );
            positions.add(model.toEntity());
          }
        }
        return positions;
      },
    );
  }
}
