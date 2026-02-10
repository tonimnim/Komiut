import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final remoteDataSource = ref.watch(bookingRemoteDataSourceProvider);
  return BookingRepositoryImpl(remoteDataSource: remoteDataSource);
});

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({required this.remoteDataSource});

  final BookingRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<Booking>>> getBookingsForTrip(String tripId) {
    return remoteDataSource.getBookingsForTrip(tripId);
  }

  @override
  Future<Either<Failure, void>> confirmBooking(String bookingId) {
    return remoteDataSource.confirmBooking(bookingId);
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId, String reason) {
    return remoteDataSource.cancelBooking(bookingId, reason);
  }

  @override
  Future<Either<Failure, void>> markAsNoShow(String bookingId) {
    return remoteDataSource.markAsNoShow(bookingId);
  }
}
