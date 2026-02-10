import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/booking.dart';
import '../models/booking_model.dart';

final bookingRemoteDataSourceProvider =
    Provider<BookingRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingRemoteDataSourceImpl(apiClient: apiClient);
});

abstract class BookingRemoteDataSource {
  Future<Either<Failure, List<Booking>>> getBookingsForTrip(String tripId);
  Future<Either<Failure, void>> confirmBooking(String bookingId);
  Future<Either<Failure, void>> cancelBooking(String bookingId, String reason);
  Future<Either<Failure, void>> markAsNoShow(String bookingId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  BookingRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Either<Failure, List<Booking>>> getBookingsForTrip(
      String tripId) async {
    return apiClient.get<List<Booking>>(
      ApiEndpoints.bookings,
      queryParameters: {'tripId': tripId},
      fromJson: (data) {
        if (data is! List) return <Booking>[];
        return data
            .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  @override
  Future<Either<Failure, void>> confirmBooking(String bookingId) async {
    return apiClient.post<void>(
      ApiEndpoints.bookingConfirm(bookingId),
    );
  }

  @override
  Future<Either<Failure, void>> cancelBooking(
    String bookingId,
    String reason,
  ) async {
    return apiClient.post<void>(
      ApiEndpoints.bookingCancel(bookingId),
      data: {'reason': reason},
    );
  }

  @override
  Future<Either<Failure, void>> markAsNoShow(String bookingId) async {
    // improved: using cancel with specific reason for no-show
    return cancelBooking(bookingId, 'No Show');
  }
}
