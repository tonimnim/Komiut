/// Booking repository interface.
///
/// Defines the contract for booking data operations.
/// Implementations handle API calls and data transformation.
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/create_booking_request.dart';
import '../entities/booking.dart';

/// Abstract repository interface for booking operations.
///
/// Uses the Either type from dartz for functional error handling.
/// All operations return Either<Failure, T> to represent success or failure.
abstract class BookingRepository {
  /// Creates a new booking.
  ///
  /// [request] - The booking creation request with trip and stop details.
  /// Returns the created [Booking] on success.
  Future<Either<Failure, Booking>> createBooking(CreateBookingRequest request);

  /// Gets a single booking by its ID.
  ///
  /// [bookingId] - The unique identifier of the booking.
  /// Returns the [Booking] if found.
  Future<Either<Failure, Booking>> getBooking(String bookingId);

  /// Gets all bookings for the current user.
  ///
  /// Returns a list of [Booking] entities.
  Future<Either<Failure, List<Booking>>> getMyBookings();

  /// Cancels a booking.
  ///
  /// [bookingId] - The ID of the booking to cancel.
  /// Returns the updated [Booking] with cancelled status.
  Future<Either<Failure, Booking>> cancelBooking(String bookingId);

  /// Confirms a booking after payment.
  ///
  /// [bookingId] - The ID of the booking to confirm.
  /// [paymentId] - The ID of the successful payment.
  /// Returns the updated [Booking] with confirmed status.
  Future<Either<Failure, Booking>> confirmBooking(
    String bookingId,
    String paymentId,
  );

  /// Gets bookings by status.
  ///
  /// [status] - The status to filter by.
  /// Returns a list of [Booking] entities matching the status.
  Future<Either<Failure, List<Booking>>> getBookingsByStatus(
    BookingStatus status,
  );

  /// Gets the user's active booking (pending or confirmed).
  ///
  /// Returns the active [Booking] if one exists, null otherwise.
  Future<Either<Failure, Booking?>> getActiveBooking();
}
