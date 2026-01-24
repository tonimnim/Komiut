/// Queue remote datasource.
///
/// Handles queue API calls to fetch vehicle queue information from the backend.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/queued_vehicle.dart';
import '../../domain/entities/vehicle_queue.dart';
import '../models/queued_vehicle_model.dart';
import '../models/vehicle_queue_model.dart';

/// Provider for queue remote datasource.
final queueRemoteDataSourceProvider = Provider<QueueRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QueueRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract queue remote datasource interface.
///
/// Defines the contract for fetching queue data from the remote API.
abstract class QueueRemoteDataSource {
  /// Fetches the queue for a specific route.
  ///
  /// [routeId] - The unique identifier of the route.
  /// Returns the [VehicleQueue] entity on success,
  /// or a [Failure] on error.
  Future<Either<Failure, VehicleQueue>> getQueueForRoute(String routeId);

  /// Fetches detailed vehicle information.
  ///
  /// [vehicleId] - The unique identifier of the vehicle.
  /// Returns the [QueuedVehicle] entity on success,
  /// or a [Failure] on error.
  Future<Either<Failure, QueuedVehicle>> getVehicleDetails(String vehicleId);

  /// Fetches all queues (for multiple routes).
  ///
  /// Returns a list of [VehicleQueue] entities on success,
  /// or a [Failure] on error.
  Future<Either<Failure, List<VehicleQueue>>> getAllQueues();

  /// Fetches the queue for a specific stage/terminal.
  ///
  /// [stageId] - The unique identifier of the stage/terminal.
  /// Returns the [VehicleQueue] entity on success,
  /// or a [Failure] on error.
  Future<Either<Failure, VehicleQueue>> getQueueForStage(String stageId);
}

/// Implementation of [QueueRemoteDataSource].
///
/// Uses [ApiClient] to make HTTP requests to the queue API endpoints.
class QueueRemoteDataSourceImpl implements QueueRemoteDataSource {
  /// Creates a queue remote datasource with the given API client.
  QueueRemoteDataSourceImpl({required this.apiClient});

  /// API client for making HTTP requests.
  final ApiClient apiClient;

  @override
  Future<Either<Failure, VehicleQueue>> getQueueForRoute(String routeId) async {
    return apiClient.get<VehicleQueue>(
      ApiEndpoints.queueByRoute(routeId),
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return VehicleQueueModel.fromJson(data).toEntity();
        }
        // Return empty queue if data format is unexpected
        return VehicleQueue.empty(routeId: routeId, routeName: '');
      },
    );
  }

  @override
  Future<Either<Failure, QueuedVehicle>> getVehicleDetails(
      String vehicleId) async {
    return apiClient.get<QueuedVehicle>(
      ApiEndpoints.vehicleById(vehicleId),
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return QueuedVehicleModel.fromJson(data).toEntity();
        }
        throw const FormatException('Invalid vehicle data format');
      },
    );
  }

  @override
  Future<Either<Failure, List<VehicleQueue>>> getAllQueues() async {
    return apiClient.get<List<VehicleQueue>>(
      ApiEndpoints.queues,
      fromJson: (data) {
        if (data is List) {
          return data
              .map((json) =>
                  VehicleQueueModel.fromJson(json as Map<String, dynamic>)
                      .toEntity())
              .toList();
        }
        return <VehicleQueue>[];
      },
    );
  }

  @override
  Future<Either<Failure, VehicleQueue>> getQueueForStage(String stageId) async {
    return apiClient.get<VehicleQueue>(
      ApiEndpoints.queueByStage(stageId),
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return VehicleQueueModel.fromJson(data).toEntity();
        }
        // Return empty queue if data format is unexpected
        return VehicleQueue.empty(routeId: '', routeName: '', stageId: stageId);
      },
    );
  }
}
