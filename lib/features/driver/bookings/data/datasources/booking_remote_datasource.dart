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

  List<dynamic> _extractItems(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final inner = data['message'];
      if (inner is Map<String, dynamic> && inner['items'] is List) {
        return inner['items'] as List;
      }
      if (data['items'] is List) {
        return data['items'] as List;
      }
    }
    return [];
  }

  @override
  Future<Either<Failure, List<Booking>>> getBookingsForTrip(
      String tripId) async {
    return apiClient.get<List<Booking>>(
      ApiEndpoints.bookings,
      queryParameters: {
        'tripId': tripId,
        'PageNumber': 1,
        'PageSize': 100,
      },
      fromJson: (data) {
        final items = _extractItems(data);
        return items
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
    return cancelBooking(bookingId, 'No Show');
  }
}
