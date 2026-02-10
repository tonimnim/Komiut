import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/booking.dart';
import '../../data/repositories/booking_repository_impl.dart';

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

  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.getBookingsForTrip(activeTrip.id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (bookings) => bookings,
  );
});

/// Provider for confirmed bookings count on active trip.
///
/// Returns 0 if loading or error.
final confirmedBookingsCountProvider = Provider<int>((ref) {
  final bookingsAsync = ref.watch(activeTripBookingsProvider);
  return bookingsAsync.whenOrNull(
        data: (bookings) => bookings
            .where((b) => b.isPaid)
            .length, // Using isPaid as proxy for confirmed/paid or check status
      ) ??
      0;
});

/// Provider for total bookings count on active trip.
///
/// Returns 0 if loading or error.
final totalBookingsCountProvider = Provider<int>((ref) {
  final bookingsAsync = ref.watch(activeTripBookingsProvider);
  return bookingsAsync.whenOrNull(data: (bookings) => bookings.length) ?? 0;
});

/// Helper to refresh active trip bookings.
void refreshActiveTripBookings(WidgetRef ref) {
  ref.invalidate(activeTripBookingsProvider);
}
