/// Trips remote datasource.
///
/// Handles trips and bookings API calls for passenger trip history.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../shared/home/domain/entities/trip_entity.dart';
import '../models/trip_api_model.dart';

/// Provider for trips remote datasource.
final tripsRemoteDataSourceProvider = Provider<TripsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TripsRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract trips remote datasource.
abstract class TripsRemoteDataSource {
  /// Gets passenger trips (via bookings).
  ///
  /// For passengers, trips are represented as bookings they've made.
  Future<Either<Failure, List<TripEntity>>> getPassengerTrips({
    required String passengerId,
    String? status,
    int? pageNumber,
    int? pageSize,
  });

  /// Gets a single trip by ID.
  Future<Either<Failure, TripEntity>> getTripById(String id);

  /// Gets recent trips for a passenger.
  Future<Either<Failure, List<TripEntity>>> getRecentTrips(
    String passengerId, {
    int limit = 5,
  });

  /// Gets trips with filters (for drivers/touts - vehicle trips).
  Future<Either<Failure, List<TripApiModel>>> getTrips({
    String? passengerId,
    String? driverId,
    String? vehicleId,
    String? status,
    int? pageNumber,
    int? pageSize,
  });
}

/// Implementation of trips remote datasource.
class TripsRemoteDataSourceImpl implements TripsRemoteDataSource {
  /// Creates a trips remote datasource.
  TripsRemoteDataSourceImpl({required this.apiClient});

  /// API client for making requests.
  final ApiClient apiClient;

  @override
  Future<Either<Failure, List<TripEntity>>> getPassengerTrips({
    required String passengerId,
    String? status,
    int? pageNumber,
    int? pageSize,
  }) async {
    // For passengers, we fetch bookings which represent their trips
    final queryParams = <String, dynamic>{
      'passengerId': passengerId,
      if (status != null) 'status': status,
      if (pageNumber != null) 'pageNumber': pageNumber,
      if (pageSize != null) 'pageSize': pageSize,
    };

    final result = await apiClient.get<List<TripEntity>>(
      ApiEndpoints.bookings,
      queryParameters: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data
              .map((json) =>
                  TripApiModel.fromBookingJson(json as Map<String, dynamic>))
              .map((model) => model.toEntity())
              .toList();
        }
        // Handle paginated response
        if (data is Map<String, dynamic> && data['items'] != null) {
          final items = data['items'] as List;
          return items
              .map((json) =>
                  TripApiModel.fromBookingJson(json as Map<String, dynamic>))
              .map((model) => model.toEntity())
              .toList();
        }
        return <TripEntity>[];
      },
    );

    return result;
  }

  @override
  Future<Either<Failure, TripEntity>> getTripById(String id) async {
    // Fetch booking by ID (passenger's trip view)
    final result = await apiClient.get<TripEntity>(
      ApiEndpoints.bookingById(id),
      fromJson: (data) {
        final model =
            TripApiModel.fromBookingJson(data as Map<String, dynamic>);
        return model.toEntity();
      },
    );

    return result;
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getRecentTrips(
    String passengerId, {
    int limit = 5,
  }) async {
    // Fetch recent bookings for the passenger
    final queryParams = <String, dynamic>{
      'passengerId': passengerId,
      'pageNumber': 1,
      'pageSize': limit,
    };

    final result = await apiClient.get<List<TripEntity>>(
      ApiEndpoints.bookings,
      queryParameters: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data
              .take(limit)
              .map((json) =>
                  TripApiModel.fromBookingJson(json as Map<String, dynamic>))
              .map((model) => model.toEntity())
              .toList();
        }
        // Handle paginated response
        if (data is Map<String, dynamic> && data['items'] != null) {
          final items = data['items'] as List;
          return items
              .take(limit)
              .map((json) =>
                  TripApiModel.fromBookingJson(json as Map<String, dynamic>))
              .map((model) => model.toEntity())
              .toList();
        }
        return <TripEntity>[];
      },
    );

    return result;
  }

  @override
  Future<Either<Failure, List<TripApiModel>>> getTrips({
    String? passengerId,
    String? driverId,
    String? vehicleId,
    String? status,
    int? pageNumber,
    int? pageSize,
  }) async {
    // For vehicle trips (driver/tout view)
    final queryParams = <String, dynamic>{
      if (driverId != null) 'driverId': driverId,
      if (vehicleId != null) 'vehicleId': vehicleId,
      if (status != null) 'status': status,
      if (pageNumber != null) 'pageNumber': pageNumber,
      if (pageSize != null) 'pageSize': pageSize,
    };

    final result = await apiClient.get<List<TripApiModel>>(
      ApiEndpoints.trips,
      queryParameters: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data
              .map((json) => TripApiModel.fromTripJson(
                    json as Map<String, dynamic>,
                    passengerId: passengerId ?? '',
                  ))
              .toList();
        }
        // Handle paginated response
        if (data is Map<String, dynamic> && data['items'] != null) {
          final items = data['items'] as List;
          return items
              .map((json) => TripApiModel.fromTripJson(
                    json as Map<String, dynamic>,
                    passengerId: passengerId ?? '',
                  ))
              .toList();
        }
        return <TripApiModel>[];
      },
    );

    return result;
  }
}
