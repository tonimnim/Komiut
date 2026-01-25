/// Routes remote datasource.
///
/// Handles routes API calls to fetch route information from the backend.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/models/route_fare_model.dart';
import '../../../../core/data/models/route_model.dart';
import '../../../../core/data/models/route_stop_model.dart';
import '../../../../core/domain/entities/route.dart';
import '../../../../core/domain/entities/route_fare.dart';
import '../../../../core/domain/entities/route_stop.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// Provider for routes remote datasource.
final routesRemoteDataSourceProvider = Provider<RoutesRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RoutesRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract routes remote datasource interface.
///
/// Defines the contract for fetching route data from the remote API.
abstract class RoutesRemoteDataSource {
  /// Fetches all available routes from the API.
  ///
  /// Returns a list of [TransportRoute] entities on success,
  /// or a [Failure] on error.
  Future<Either<Failure, List<TransportRoute>>> getRoutes();

  /// Fetches a single route by its ID.
  ///
  /// [id] - The unique identifier of the route.
  /// Returns the [TransportRoute] entity on success,
  /// or a [Failure] on error.
  Future<Either<Failure, TransportRoute>> getRouteById(String id);

  /// Fetches all stops for a specific route.
  ///
  /// [routeId] - The unique identifier of the route.
  /// Returns a list of [RouteStop] entities on success,
  /// or a [Failure] on error.
  Future<Either<Failure, List<RouteStop>>> getRouteStops(String routeId);

  /// Fetches all fares for a specific route.
  ///
  /// [routeId] - The unique identifier of the route.
  /// Returns a list of [RouteFare] entities on success,
  /// or a [Failure] on error.
  Future<Either<Failure, List<RouteFare>>> getRouteFares(String routeId);
}

/// Implementation of [RoutesRemoteDataSource].
///
/// Uses [ApiClient] to make HTTP requests to the routes API endpoints.
class RoutesRemoteDataSourceImpl implements RoutesRemoteDataSource {
  /// Creates a routes remote datasource with the given API client.
  RoutesRemoteDataSourceImpl({required this.apiClient});

  /// API client for making HTTP requests.
  final ApiClient apiClient;

  @override
  Future<Either<Failure, List<TransportRoute>>> getRoutes() async {
    return apiClient.get<List<TransportRoute>>(
      ApiEndpoints.routes,
      fromJson: (data) {
        if (data is List) {
          return data
              .map((json) =>
                  RouteModel.fromJson(json as Map<String, dynamic>).toEntity())
              .toList();
        }
        return <TransportRoute>[];
      },
    );
  }

  @override
  Future<Either<Failure, TransportRoute>> getRouteById(String id) async {
    return apiClient.get<TransportRoute>(
      ApiEndpoints.routeById(id),
      fromJson: (data) =>
          RouteModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<RouteStop>>> getRouteStops(String routeId) async {
    return apiClient.get<List<RouteStop>>(
      ApiEndpoints.routeStops,
      queryParameters: {'routeId': routeId},
      fromJson: (data) {
        if (data is List) {
          return data
              .map((json) =>
                  RouteStopModel.fromJson(json as Map<String, dynamic>)
                      .toEntity())
              .toList()
            ..sort((a, b) => a.sequence.compareTo(b.sequence));
        }
        return <RouteStop>[];
      },
    );
  }

  @override
  Future<Either<Failure, List<RouteFare>>> getRouteFares(String routeId) async {
    return apiClient.get<List<RouteFare>>(
      ApiEndpoints.routeFares,
      queryParameters: {'routeId': routeId},
      fromJson: (data) {
        if (data is List) {
          return data
              .map((json) =>
                  RouteFareModel.fromJson(json as Map<String, dynamic>)
                      .toEntity())
              .toList();
        }
        return <RouteFare>[];
      },
    );
  }
}
