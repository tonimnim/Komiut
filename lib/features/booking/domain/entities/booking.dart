/// Booking domain entity.
///
/// Represents a transport booking made by a passenger.
/// Contains all booking-related data including trip details,
/// stops, payment info, and status tracking.
library;

/// Booking status enum representing all possible states.
enum BookingStatus {
  /// Booking created but not yet paid/confirmed.
  pending,

  /// Booking paid and confirmed.
  confirmed,

  /// Booking was cancelled by user or system.
  cancelled,

  /// Trip completed successfully.
  completed,

  /// Booking expired before payment/confirmation.
  expired;

  /// Returns true if the booking is in an active state.
  bool get isActive => this == pending || this == confirmed;

  /// Returns true if the booking is in a terminal state.
  bool get isTerminal => this == cancelled || this == completed || this == expired;

  /// Returns true if the booking can be cancelled.
  bool get canCancel => this == pending || this == confirmed;

  /// Returns a user-friendly label for the status.
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending Payment';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.expired:
        return 'Expired';
    }
  }
}

/// Represents a booking entity in the domain layer.
///
/// This is an immutable value object that contains all
/// the information about a passenger's booking.
class Booking {
  /// Creates a new Booking instance.
  const Booking({
    required this.id,
    required this.passengerId,
    required this.tripId,
    required this.vehicleId,
    required this.routeId,
    this.seatNumber,
    required this.pickupStopId,
    required this.dropoffStopId,
    required this.amount,
    required this.currency,
    required this.status,
    this.paymentId,
    required this.createdAt,
    this.confirmedAt,
    this.expiresAt,
  });

  /// Unique identifier for the booking.
  final String id;

  /// ID of the passenger who made the booking.
  final String passengerId;

  /// ID of the trip this booking is for.
  final String tripId;

  /// ID of the vehicle assigned to the trip.
  final String vehicleId;

  /// ID of the route the trip follows.
  final String routeId;

  /// Seat number if assigned (optional for some vehicles).
  final int? seatNumber;

  /// ID of the stop where passenger will board.
  final String pickupStopId;

  /// ID of the stop where passenger will alight.
  final String dropoffStopId;

  /// Total amount to pay for the booking.
  final double amount;

  /// Currency code (e.g., 'KES', 'UGX', 'TZS').
  final String currency;

  /// Current status of the booking.
  final BookingStatus status;

  /// ID of the payment if booking is paid.
  final String? paymentId;

  /// Timestamp when booking was created.
  final DateTime createdAt;

  /// Timestamp when booking was confirmed (after payment).
  final DateTime? confirmedAt;

  /// Timestamp when pending booking will expire.
  final DateTime? expiresAt;

  // ─────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────

  /// Whether the booking is pending payment.
  bool get isPending => status == BookingStatus.pending;

  /// Whether the booking is confirmed.
  bool get isConfirmed => status == BookingStatus.confirmed;

  /// Whether the booking is cancelled.
  bool get isCancelled => status == BookingStatus.cancelled;

  /// Whether the booking is completed.
  bool get isCompleted => status == BookingStatus.completed;

  /// Whether the booking is expired.
  bool get isExpired => status == BookingStatus.expired;

  /// Whether the booking is in an active (non-terminal) state.
  bool get isActive => status.isActive;

  /// Whether the booking can be cancelled.
  bool get canBeCancelled => status.canCancel;

  /// Whether the booking has a payment associated.
  bool get isPaid => paymentId != null;

  /// Whether the booking has a seat assigned.
  bool get hasSeat => seatNumber != null;

  /// Formatted amount with currency.
  String get formattedAmount => '$currency ${amount.toStringAsFixed(0)}';

  /// Time remaining until expiry (if pending).
  Duration? get timeUntilExpiry {
    if (expiresAt == null || !isPending) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Whether the booking has expired based on current time.
  bool get hasExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Copy With
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates a copy with modified fields.
  Booking copyWith({
    String? id,
    String? passengerId,
    String? tripId,
    String? vehicleId,
    String? routeId,
    int? seatNumber,
    String? pickupStopId,
    String? dropoffStopId,
    double? amount,
    String? currency,
    BookingStatus? status,
    String? paymentId,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? expiresAt,
  }) {
    return Booking(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      tripId: tripId ?? this.tripId,
      vehicleId: vehicleId ?? this.vehicleId,
      routeId: routeId ?? this.routeId,
      seatNumber: seatNumber ?? this.seatNumber,
      pickupStopId: pickupStopId ?? this.pickupStopId,
      dropoffStopId: dropoffStopId ?? this.dropoffStopId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Booking &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          passengerId == other.passengerId &&
          tripId == other.tripId &&
          vehicleId == other.vehicleId &&
          routeId == other.routeId &&
          seatNumber == other.seatNumber &&
          pickupStopId == other.pickupStopId &&
          dropoffStopId == other.dropoffStopId &&
          amount == other.amount &&
          currency == other.currency &&
          status == other.status &&
          paymentId == other.paymentId;

  @override
  int get hashCode =>
      id.hashCode ^
      passengerId.hashCode ^
      tripId.hashCode ^
      vehicleId.hashCode ^
      routeId.hashCode ^
      seatNumber.hashCode ^
      pickupStopId.hashCode ^
      dropoffStopId.hashCode ^
      amount.hashCode ^
      currency.hashCode ^
      status.hashCode ^
      paymentId.hashCode;

  @override
  String toString() =>
      'Booking(id: $id, tripId: $tripId, status: ${status.name}, amount: $formattedAmount)';
}
