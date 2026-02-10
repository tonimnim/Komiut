/// Booking remote datasource.
///
/// Handles booking-related API calls to the backend.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/booking.dart';
import '../models/booking_model.dart';
import '../models/create_booking_request.dart';

/// Provider for booking remote datasource.
final bookingRemoteDataSourceProvider =
    Provider<BookingRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract booking remote datasource interface.
///
/// Defines the contract for booking-related API operations.
abstract class BookingRemoteDataSource {
  /// Creates a new booking.
  ///
  /// POST /api/Bookings
  /// [request] - The booking creation request.
  /// Returns the created [Booking] on success.
  Future<Either<Failure, Booking>> createBooking(CreateBookingRequest request);

  /// Gets a booking by ID.
  ///
  /// GET /api/Bookings/{id}
  /// [bookingId] - The unique identifier of the booking.
  Future<Either<Failure, Booking>> getBooking(String bookingId);

  /// Gets all bookings for the current user.
  ///
  /// GET /api/Bookings/my
  /// Returns a list of [Booking] entities.
  Future<Either<Failure, List<Booking>>> getMyBookings();

  /// Cancels a booking.
  ///
  /// PUT /api/Bookings/{id}/cancel
  /// [bookingId] - The ID of the booking to cancel.
  Future<Either<Failure, Booking>> cancelBooking(String bookingId);

  /// Confirms a booking after payment.
  ///
  /// PUT /api/Bookings/{id}/confirm
  /// [bookingId] - The ID of the booking to confirm.
  /// [paymentId] - The ID of the successful payment.
  Future<Either<Failure, Booking>> confirmBooking(
    String bookingId,
    String paymentId,
  );

  /// Gets bookings filtered by status.
  ///
  /// GET /api/Bookings/my?status={status}
  /// [status] - The status to filter by.
  Future<Either<Failure, List<Booking>>> getBookingsByStatus(
    BookingStatus status,
  );
}

/// Implementation of [BookingRemoteDataSource].
///
/// Uses [ApiClient] to make HTTP requests to the booking API endpoints.
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  /// Creates a booking remote datasource with the given API client.
  BookingRemoteDataSourceImpl({required this.apiClient});

  /// API client for making HTTP requests.
  final ApiClient apiClient;

  /// Unwraps the backend's {"message": {...}} envelope.
  Map<String, dynamic> _unwrapMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['message'];
      if (inner is Map<String, dynamic>) return inner;
      return data;
    }
    return {};
  }

  /// Extracts items list from paginated envelope.
  List<dynamic> _extractItems(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final inner = data['message'];
      if (inner is Map<String, dynamic> && inner['items'] is List) {
        return inner['items'] as List;
      }
      if (data['items'] is List) return data['items'] as List;
    }
    return [];
  }

  @override
  Future<Either<Failure, Booking>> createBooking(
    CreateBookingRequest request,
  ) async {
    return apiClient.post<Booking>(
      ApiEndpoints.bookings,
      data: request.toJson(),
      fromJson: (data) =>
          BookingModel.fromJson(_unwrapMessage(data)).toEntity(),
    );
  }

  @override
  Future<Either<Failure, Booking>> getBooking(String bookingId) async {
    return apiClient.get<Booking>(
      ApiEndpoints.bookingById(bookingId),
      fromJson: (data) =>
          BookingModel.fromJson(_unwrapMessage(data)).toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<Booking>>> getMyBookings() async {
    return apiClient.get<List<Booking>>(
      ApiEndpoints.bookings,
      queryParameters: {'PageNumber': 1, 'PageSize': 50},
      fromJson: (data) {
        final items = _extractItems(data);
        final bookings = items
            .map((item) =>
                BookingModel.fromJson(item as Map<String, dynamic>).toEntity())
            .toList();
        bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return bookings;
      },
    );
  }

  @override
  Future<Either<Failure, Booking>> cancelBooking(String bookingId) async {
    return apiClient.put<Booking>(
      ApiEndpoints.bookingCancel(bookingId),
      fromJson: (data) =>
          BookingModel.fromJson(_unwrapMessage(data)).toEntity(),
    );
  }

  @override
  Future<Either<Failure, Booking>> confirmBooking(
    String bookingId,
    String paymentId,
  ) async {
    final request = ConfirmBookingRequest(paymentId: paymentId);
    return apiClient.put<Booking>(
      ApiEndpoints.bookingConfirm(bookingId),
      data: request.toJson(),
      fromJson: (data) =>
          BookingModel.fromJson(_unwrapMessage(data)).toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<Booking>>> getBookingsByStatus(
    BookingStatus status,
  ) async {
    return apiClient.get<List<Booking>>(
      ApiEndpoints.bookings,
      queryParameters: {
        'Status': status.index,
        'PageNumber': 1,
        'PageSize': 50,
      },
      fromJson: (data) {
        final items = _extractItems(data);
        final bookings = items
            .map((item) =>
                BookingModel.fromJson(item as Map<String, dynamic>).toEntity())
            .toList();
        bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return bookings;
      },
    );
  }
}
