import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/booking.dart';

abstract class BookingRepository {
  Future<Either<Failure, List<Booking>>> getBookingsForTrip(String tripId);
  Future<Either<Failure, void>> confirmBooking(String bookingId);
  Future<Either<Failure, void>> cancelBooking(String bookingId, String reason);
  Future<Either<Failure, void>> markAsNoShow(String bookingId);
}
