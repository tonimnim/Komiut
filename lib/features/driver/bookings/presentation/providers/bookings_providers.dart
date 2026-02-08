/// Booking providers for driver's active trip.
///
/// Provides bookings for the driver's current active trip.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/domain/entities/booking.dart';
import '../../../../passenger/trips/data/datasources/bookings_remote_datasource.dart';
import '../../../trips/presentation/providers/trips_providers.dart';

/// Provider for bookings on the driver's active trip.
///
/// Watches [activeTripProvider] and fetches bookings for that trip.
/// Returns empty list if no active trip.
final activeTripBookingsProvider =
    FutureProvider.autoDispose<List<Booking>>((ref) async {
  // Watch for active trip changes
  final activeTrip = await ref.watch(activeTripProvider.future);

  if (activeTrip == null) {
    return [];
  }

  final dataSource = ref.watch(bookingsRemoteDataSourceProvider);
  final result = await dataSource.getBookings(tripId: activeTrip.id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (bookings) => bookings,
  );
});

/// Provider for confirmed bookings count on active trip.
final confirmedBookingsCountProvider = Provider<int>((ref) {
  final bookingsAsync = ref.watch(activeTripBookingsProvider);
  return bookingsAsync.whenOrNull(
        data: (bookings) => bookings.where((b) => b.isConfirmed).length,
      ) ??
      0;
});

/// Provider for total bookings count on active trip.
final totalBookingsCountProvider = Provider<int>((ref) {
  final bookingsAsync = ref.watch(activeTripBookingsProvider);
  return bookingsAsync.whenOrNull(data: (bookings) => bookings.length) ?? 0;
});

/// Helper to refresh active trip bookings.
void refreshActiveTripBookings(WidgetRef ref) {
  ref.invalidate(activeTripBookingsProvider);
}
