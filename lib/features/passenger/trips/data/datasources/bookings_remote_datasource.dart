/// Bookings remote datasource.
///
/// Handles booking API calls for passengers to book seats on trips.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/data/models/booking_model.dart';
import '../../../../../core/domain/entities/booking.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';

/// Provider for bookings remote datasource.
final bookingsRemoteDataSourceProvider =
    Provider<BookingsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingsRemoteDataSourceImpl(apiClient: apiClient);
});

/// Request model for creating a booking.
class CreateBookingRequest {
  const CreateBookingRequest({
    required this.tripId,
    required this.passengerId,
    required this.pickupStopId,
    required this.dropoffStopId,
    this.seatNumber,
  });

  final String tripId;
  final String passengerId;
  final String pickupStopId;
  final String dropoffStopId;
  final String? seatNumber;

  Map<String, dynamic> toJson() => {
        'tripId': tripId,
        'passengerId': passengerId,
        'pickupPointId': pickupStopId,
        'dropoffPointId': dropoffStopId,
        if (seatNumber != null) 'seatNumber': seatNumber,
      };
}

/// Abstract bookings remote datasource.
abstract class BookingsRemoteDataSource {
  /// Creates a new booking for a passenger.
  Future<Either<Failure, Booking>> createBooking(CreateBookingRequest request);

  /// Gets a booking by ID.
  Future<Either<Failure, Booking>> getBookingById(String id);

  /// Gets all bookings for a passenger.
  Future<Either<Failure, List<Booking>>> getPassengerBookings(
    String passengerId, {
    String? status,
    int? pageNumber,
    int? pageSize,
  });

  /// Cancels a booking.
  Future<Either<Failure, void>> cancelBooking(String bookingId);

  /// Gets all bookings with filters.
  Future<Either<Failure, List<Booking>>> getBookings({
    String? passengerId,
    String? tripId,
    String? status,
    int? pageNumber,
    int? pageSize,
  });
}

/// Implementation of bookings remote datasource.
class BookingsRemoteDataSourceImpl implements BookingsRemoteDataSource {
  /// Creates a bookings remote datasource.
  BookingsRemoteDataSourceImpl({required this.apiClient});

  /// API client for making requests.
  final ApiClient apiClient;

  @override
  Future<Either<Failure, Booking>> createBooking(
      CreateBookingRequest request) async {
    return apiClient.post<Booking>(
      ApiEndpoints.bookings,
      data: request.toJson(),
      fromJson: (data) =>
          BookingModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );
  }

  @override
  Future<Either<Failure, Booking>> getBookingById(String id) async {
    return apiClient.get<Booking>(
      ApiEndpoints.bookingById(id),
      fromJson: (data) =>
          BookingModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<Booking>>> getPassengerBookings(
    String passengerId, {
    String? status,
    int? pageNumber,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{
      'passengerId': passengerId,
      if (status != null) 'status': status,
      if (pageNumber != null) 'pageNumber': pageNumber,
      if (pageSize != null) 'pageSize': pageSize,
    };

    return apiClient.get<List<Booking>>(
      ApiEndpoints.bookings,
      queryParameters: queryParams,
      fromJson: (data) => _parseBookingsList(data),
    );
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    final result = await apiClient.delete<void>(
      ApiEndpoints.bookingById(bookingId),
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, List<Booking>>> getBookings({
    String? passengerId,
    String? tripId,
    String? status,
    int? pageNumber,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{
      if (passengerId != null) 'passengerId': passengerId,
      if (tripId != null) 'tripId': tripId,
      if (status != null) 'status': status,
      if (pageNumber != null) 'pageNumber': pageNumber,
      if (pageSize != null) 'pageSize': pageSize,
    };

    return apiClient.get<List<Booking>>(
      ApiEndpoints.bookings,
      queryParameters: queryParams,
      fromJson: (data) => _parseBookingsList(data),
    );
  }

  /// Parse bookings list from API response.
  List<Booking> _parseBookingsList(dynamic data) {
    if (data is List) {
      return data
          .map((json) =>
              BookingModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    }
    // Handle paginated response
    if (data is Map<String, dynamic> && data['items'] != null) {
      final items = data['items'] as List;
      return items
          .map((json) =>
              BookingModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    }
    return <Booking>[];
  }
}
