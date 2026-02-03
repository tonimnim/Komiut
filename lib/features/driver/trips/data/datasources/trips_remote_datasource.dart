import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/driver_trip.dart';
import '../models/driver_trip_model.dart';

/// Provider for trips remote data source.
final tripsRemoteDataSourceProvider = Provider<TripsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TripsRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract interface for trips data operations.
abstract class TripsRemoteDataSource {
  /// Gets trips for a vehicle.
  Future<Either<Failure, List<DriverTrip>>> getTrips({
    String? vehicleId,
    String? routeId,
    DriverTripStatus? status,
    int? pageNumber,
    int? pageSize,
  });

  /// Gets active trip for a vehicle.
  Future<Either<Failure, DriverTrip?>> getActiveTrip(String vehicleId);

  /// Starts a new trip.
  Future<Either<Failure, DriverTrip>> startTrip({
    required String vehicleId,
    required String routeId,
    required String driverId,
    String? toutId,
  });

  /// Ends a trip.
  Future<Either<Failure, void>> endTrip({
    required String tripId,
    String? reason,
  });

  /// Updates trip status.
  Future<Either<Failure, void>> updateTripStatus({
    required String tripId,
    required DriverTripStatus status,
    String? reason,
  });
}

/// Implementation of trips remote data source.
class TripsRemoteDataSourceImpl implements TripsRemoteDataSource {
  TripsRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Either<Failure, List<DriverTrip>>> getTrips({
    String? vehicleId,
    String? routeId,
    DriverTripStatus? status,
    int? pageNumber,
    int? pageSize,
  }) async {
    return apiClient.get<List<DriverTrip>>(
      ApiEndpoints.trips,
      queryParameters: {
        if (vehicleId != null) 'VehicleId': vehicleId,
        if (routeId != null) 'RouteId': routeId,
        if (status != null)
          'Status': DriverTripModel.statusToInt(status).toString(),
        if (pageNumber != null) 'PageNumber': pageNumber.toString(),
        if (pageSize != null) 'PageSize': pageSize.toString(),
      },
      fromJson: (data) {
        if (data is! List) return <DriverTrip>[];
        return data
            .map((json) => DriverTripModel.fromJson(
                  json as Map<String, dynamic>,
                ).toEntity())
            .toList();
      },
    );
  }

  @override
  Future<Either<Failure, DriverTrip?>> getActiveTrip(String vehicleId) async {
    final result = await getTrips(
      vehicleId: vehicleId,
      status: DriverTripStatus.active,
      pageSize: 1,
    );

    return result.fold(
      (failure) => Left(failure),
      (trips) => Right(trips.isNotEmpty ? trips.first : null),
    );
  }

  @override
  Future<Either<Failure, DriverTrip>> startTrip({
    required String vehicleId,
    required String routeId,
    required String driverId,
    String? toutId,
  }) async {
    return apiClient.post<DriverTrip>(
      ApiEndpoints.trips,
      data: {
        'vehicleId': vehicleId,
        'routeId': routeId,
        'driverId': driverId,
        if (toutId != null) 'toutId': toutId,
        'startTime': DateTime.now().toIso8601String(),
      },
      fromJson: (data) => DriverTripModel.fromJson(
        data as Map<String, dynamic>,
      ).toEntity(),
    );
  }

  @override
  Future<Either<Failure, void>> endTrip({
    required String tripId,
    String? reason,
  }) async {
    return updateTripStatus(
      tripId: tripId,
      status: DriverTripStatus.completed,
      reason: reason,
    );
  }

  @override
  Future<Either<Failure, void>> updateTripStatus({
    required String tripId,
    required DriverTripStatus status,
    String? reason,
  }) async {
    return apiClient.put<void>(
      ApiEndpoints.trips,
      data: {
        'tripId': tripId,
        'status': DriverTripModel.statusToInt(status),
        if (reason != null) 'reason': reason,
      },
    );
  }
}
