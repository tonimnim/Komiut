/// Booking feature providers.
///
/// Provides all booking-related state management and dependencies.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/booking_remote_datasource.dart';
import '../../data/models/create_booking_request.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repository Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the booking repository.
///
/// Uses the remote datasource for API operations.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final remoteDataSource = ref.watch(bookingRemoteDataSourceProvider);
  return BookingRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ─────────────────────────────────────────────────────────────────────────────
// Booking List Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for fetching the current user's bookings.
///
/// Returns all bookings for the authenticated user.
final myBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.getMyBookings();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (bookings) => bookings,
  );
});

/// Provider for fetching a single booking by ID.
///
/// [bookingId] - The unique identifier of the booking.
final bookingByIdProvider =
    FutureProvider.family<Booking, String>((ref, bookingId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.getBooking(bookingId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (booking) => booking,
  );
});

/// Provider for fetching bookings by status.
///
/// [status] - The booking status to filter by.
final bookingsByStatusProvider =
    FutureProvider.family<List<Booking>, BookingStatus>((ref, status) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.getBookingsByStatus(status);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (bookings) => bookings,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Active Booking Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for the user's current active booking.
///
/// Returns the active booking (pending or confirmed) if one exists.
/// Returns null if no active booking.
final activeBookingProvider = FutureProvider<Booking?>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.getActiveBooking();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (booking) => booking,
  );
});

/// State notifier for managing active booking state.
///
/// Provides real-time updates for the active booking including
/// status changes and expiry countdown.
final activeBookingStateProvider =
    StateNotifierProvider<ActiveBookingNotifier, AsyncValue<Booking?>>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return ActiveBookingNotifier(repository, ref);
});

/// Notifier for active booking state management.
class ActiveBookingNotifier extends StateNotifier<AsyncValue<Booking?>> {
  ActiveBookingNotifier(this._repository, Ref ref)
      : super(const AsyncValue.loading()) {
    _fetchActiveBooking();
  }

  final BookingRepository _repository;
  Timer? _refreshTimer;

  /// Fetches the active booking from the repository.
  Future<void> _fetchActiveBooking() async {
    state = const AsyncValue.loading();

    final result = await _repository.getActiveBooking();
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (booking) {
        // Set up periodic refresh if there's an active booking
        if (booking != null && booking.isPending) {
          _startRefreshTimer();
        }
        return AsyncValue.data(booking);
      },
    );
  }

  /// Starts a timer to periodically refresh the booking.
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => refresh(),
    );
  }

  /// Refreshes the active booking data.
  Future<void> refresh() async {
    final result = await _repository.getActiveBooking();
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (booking) => AsyncValue.data(booking),
    );
  }

  /// Clears the active booking state.
  void clear() {
    _refreshTimer?.cancel();
    state = const AsyncValue.data(null);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking Action Providers
// ─────────────────────────────────────────────────────────────────────────────

/// State for booking creation.
class CreateBookingState {
  const CreateBookingState({
    this.isLoading = false,
    this.booking,
    this.error,
  });

  final bool isLoading;
  final Booking? booking;
  final String? error;

  CreateBookingState copyWith({
    bool? isLoading,
    Booking? booking,
    String? error,
  }) {
    return CreateBookingState(
      isLoading: isLoading ?? this.isLoading,
      booking: booking ?? this.booking,
      error: error,
    );
  }
}

/// Provider for creating a new booking.
///
/// Manages the booking creation flow including loading state and error handling.
final createBookingProvider =
    StateNotifierProvider<CreateBookingNotifier, CreateBookingState>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return CreateBookingNotifier(repository, ref);
});

/// Notifier for booking creation.
class CreateBookingNotifier extends StateNotifier<CreateBookingState> {
  CreateBookingNotifier(this._repository, this._ref)
      : super(const CreateBookingState());

  final BookingRepository _repository;
  final Ref _ref;

  /// Creates a new booking with the given request.
  Future<Booking?> createBooking(CreateBookingRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.createBooking(request);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (booking) {
        state = state.copyWith(isLoading: false, booking: booking);
        // Invalidate related providers
        _ref.invalidate(myBookingsProvider);
        _ref.invalidate(activeBookingProvider);
        return booking;
      },
    );
  }

  /// Resets the state.
  void reset() {
    state = const CreateBookingState();
  }
}

/// State for cancel booking action.
class CancelBookingState {
  const CancelBookingState({
    this.isLoading = false,
    this.cancelledBooking,
    this.error,
  });

  final bool isLoading;
  final Booking? cancelledBooking;
  final String? error;

  CancelBookingState copyWith({
    bool? isLoading,
    Booking? cancelledBooking,
    String? error,
  }) {
    return CancelBookingState(
      isLoading: isLoading ?? this.isLoading,
      cancelledBooking: cancelledBooking ?? this.cancelledBooking,
      error: error,
    );
  }
}

/// Provider for cancelling a booking.
final cancelBookingProvider =
    StateNotifierProvider<CancelBookingNotifier, CancelBookingState>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return CancelBookingNotifier(repository, ref);
});

/// Notifier for booking cancellation.
class CancelBookingNotifier extends StateNotifier<CancelBookingState> {
  CancelBookingNotifier(this._repository, this._ref)
      : super(const CancelBookingState());

  final BookingRepository _repository;
  final Ref _ref;

  /// Cancels a booking by its ID.
  Future<bool> cancelBooking(String bookingId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.cancelBooking(bookingId);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (booking) {
        state = state.copyWith(isLoading: false, cancelledBooking: booking);
        // Invalidate related providers
        _ref.invalidate(myBookingsProvider);
        _ref.invalidate(activeBookingProvider);
        _ref.invalidate(bookingByIdProvider(bookingId));
        return true;
      },
    );
  }

  /// Resets the state.
  void reset() {
    state = const CancelBookingState();
  }
}

/// State for confirm booking action.
class ConfirmBookingState {
  const ConfirmBookingState({
    this.isLoading = false,
    this.confirmedBooking,
    this.error,
  });

  final bool isLoading;
  final Booking? confirmedBooking;
  final String? error;

  ConfirmBookingState copyWith({
    bool? isLoading,
    Booking? confirmedBooking,
    String? error,
  }) {
    return ConfirmBookingState(
      isLoading: isLoading ?? this.isLoading,
      confirmedBooking: confirmedBooking ?? this.confirmedBooking,
      error: error,
    );
  }
}

/// Provider for confirming a booking after payment.
final confirmBookingProvider =
    StateNotifierProvider<ConfirmBookingNotifier, ConfirmBookingState>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return ConfirmBookingNotifier(repository, ref);
});

/// Notifier for booking confirmation.
class ConfirmBookingNotifier extends StateNotifier<ConfirmBookingState> {
  ConfirmBookingNotifier(this._repository, this._ref)
      : super(const ConfirmBookingState());

  final BookingRepository _repository;
  final Ref _ref;

  /// Confirms a booking with the payment ID.
  Future<bool> confirmBooking(String bookingId, String paymentId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.confirmBooking(bookingId, paymentId);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (booking) {
        state = state.copyWith(isLoading: false, confirmedBooking: booking);
        // Invalidate related providers
        _ref.invalidate(myBookingsProvider);
        _ref.invalidate(activeBookingProvider);
        _ref.invalidate(bookingByIdProvider(bookingId));
        return true;
      },
    );
  }

  /// Resets the state.
  void reset() {
    state = const ConfirmBookingState();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking Expiry Timer Provider
// ─────────────────────────────────────────────────────────────────────────────

/// State for the booking expiry countdown.
class BookingExpiryState {
  const BookingExpiryState({
    this.timeRemaining,
    this.isExpired = false,
  });

  final Duration? timeRemaining;
  final bool isExpired;

  String get formattedTime {
    if (timeRemaining == null || isExpired) return '00:00';

    final minutes = timeRemaining!.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = timeRemaining!.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    if (timeRemaining == null || isExpired) return 0.0;
    // Assuming 10 minutes (600 seconds) is the default expiry time
    const totalSeconds = 600;
    final remaining = timeRemaining!.inSeconds.clamp(0, totalSeconds);
    return remaining / totalSeconds;
  }
}

/// Provider for tracking booking expiry countdown.
///
/// Automatically updates every second when there's a pending booking.
final bookingExpiryTimerProvider =
    StateNotifierProvider<BookingExpiryTimerNotifier, BookingExpiryState>((ref) {
  return BookingExpiryTimerNotifier(ref);
});

/// Notifier for booking expiry countdown.
class BookingExpiryTimerNotifier extends StateNotifier<BookingExpiryState> {
  BookingExpiryTimerNotifier(this._ref) : super(const BookingExpiryState()) {
    // Listen to active booking changes
    _ref.listen(activeBookingProvider, (previous, next) {
      next.whenData((booking) {
        if (booking != null && booking.isPending && booking.expiresAt != null) {
          _startTimer(booking.expiresAt!);
        } else {
          _stopTimer();
          state = const BookingExpiryState();
        }
      });
    });
  }

  final Ref _ref;
  Timer? _timer;
  DateTime? _expiresAt;

  /// Starts the countdown timer.
  void _startTimer(DateTime expiresAt) {
    _stopTimer();
    _expiresAt = expiresAt;
    _updateTimeRemaining();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateTimeRemaining(),
    );
  }

  /// Updates the time remaining.
  void _updateTimeRemaining() {
    if (_expiresAt == null) return;

    final now = DateTime.now();
    final remaining = _expiresAt!.difference(now);

    if (remaining.isNegative) {
      state = const BookingExpiryState(isExpired: true);
      _stopTimer();
      // Refresh the active booking to reflect expired status
      _ref.invalidate(activeBookingProvider);
    } else {
      state = BookingExpiryState(timeRemaining: remaining);
    }
  }

  /// Stops the countdown timer.
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Manually starts a countdown for a specific expiry time.
  void startCountdown(DateTime expiresAt) {
    _startTimer(expiresAt);
  }

  /// Stops the countdown and resets state.
  void stop() {
    _stopTimer();
    state = const BookingExpiryState();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Utility Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for refreshing all booking data.
///
/// Call this to force a refresh of all booking-related providers.
final refreshBookingsProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    ref.invalidate(myBookingsProvider);
    ref.invalidate(activeBookingProvider);
  };
});

/// Provider for filtering bookings by status from the cached list.
final filteredBookingsProvider =
    Provider.family<AsyncValue<List<Booking>>, BookingStatus?>((ref, status) {
  final bookingsAsync = ref.watch(myBookingsProvider);

  return bookingsAsync.whenData((bookings) {
    if (status == null) return bookings;
    return bookings.where((b) => b.status == status).toList();
  });
});

/// Provider for pending bookings only.
final pendingBookingsProvider = Provider<AsyncValue<List<Booking>>>((ref) {
  return ref.watch(filteredBookingsProvider(BookingStatus.pending));
});

/// Provider for confirmed bookings only.
final confirmedBookingsProvider = Provider<AsyncValue<List<Booking>>>((ref) {
  return ref.watch(filteredBookingsProvider(BookingStatus.confirmed));
});

/// Provider for completed bookings (history).
final completedBookingsProvider = Provider<AsyncValue<List<Booking>>>((ref) {
  return ref.watch(filteredBookingsProvider(BookingStatus.completed));
});

/// Provider for checking if user has an active booking.
final hasActiveBookingProvider = Provider<AsyncValue<bool>>((ref) {
  final activeBookingAsync = ref.watch(activeBookingProvider);
  return activeBookingAsync.whenData((booking) => booking != null);
});
