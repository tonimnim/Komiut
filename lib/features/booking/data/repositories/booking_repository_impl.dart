/// Booking repository implementation.
///
/// Implements the booking repository with error handling and
/// data transformation from API responses to domain entities.
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/create_booking_request.dart';

/// Implementation of [BookingRepository].
///
/// Uses [BookingRemoteDataSource] for all API operations.
/// Handles error transformation and provides consistent error handling.
class BookingRepositoryImpl implements BookingRepository {
  /// Creates a booking repository with the given remote datasource.
  const BookingRepositoryImpl({
    required BookingRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final BookingRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Booking>> createBooking(
    CreateBookingRequest request,
  ) async {
    try {
      return await _remoteDataSource.createBooking(request);
    } catch (e) {
      return Left(ServerFailure('Failed to create booking: $e'));
    }
  }

  @override
  Future<Either<Failure, Booking>> getBooking(String bookingId) async {
    try {
      return await _remoteDataSource.getBooking(bookingId);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch booking: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getMyBookings() async {
    try {
      return await _remoteDataSource.getMyBookings();
    } catch (e) {
      return Left(ServerFailure('Failed to fetch bookings: $e'));
    }
  }

  @override
  Future<Either<Failure, Booking>> cancelBooking(String bookingId) async {
    try {
      return await _remoteDataSource.cancelBooking(bookingId);
    } catch (e) {
      return Left(ServerFailure('Failed to cancel booking: $e'));
    }
  }

  @override
  Future<Either<Failure, Booking>> confirmBooking(
    String bookingId,
    String paymentId,
  ) async {
    try {
      return await _remoteDataSource.confirmBooking(bookingId, paymentId);
    } catch (e) {
      return Left(ServerFailure('Failed to confirm booking: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getBookingsByStatus(
    BookingStatus status,
  ) async {
    try {
      return await _remoteDataSource.getBookingsByStatus(status);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch bookings by status: $e'));
    }
  }

  @override
  Future<Either<Failure, Booking?>> getActiveBooking() async {
    try {
      // First check for pending bookings
      final pendingResult = await _remoteDataSource.getBookingsByStatus(
        BookingStatus.pending,
      );

      return pendingResult.fold(
        (failure) => Left(failure),
        (pendingBookings) async {
          // Return the first non-expired pending booking
          final activePending = pendingBookings
              .where((b) => !b.hasExpired)
              .toList();

          if (activePending.isNotEmpty) {
            return Right(activePending.first);
          }

          // No pending bookings, check for confirmed
          final confirmedResult = await _remoteDataSource.getBookingsByStatus(
            BookingStatus.confirmed,
          );

          return confirmedResult.fold(
            (failure) => Left(failure),
            (confirmedBookings) {
              if (confirmedBookings.isNotEmpty) {
                return Right(confirmedBookings.first);
              }
              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to fetch active booking: $e'));
    }
  }
}
