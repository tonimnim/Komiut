/// Booking entity.
///
/// Represents a passenger's booking for a trip.
library;

import 'package:equatable/equatable.dart';

import '../enums/enums.dart';

/// Booking entity representing a seat reservation.
class Booking extends Equatable {
  /// Creates a new Booking instance.
  const Booking({
    required this.id,
    required this.passengerId,
    required this.tripId,
    this.seatNumber,
    required this.pickupStopId,
    required this.dropoffStopId,
    required this.amount,
    required this.currency,
    required this.status,
    this.passengerName,
    this.passengerPhone,
    this.pickupStopName,
    this.dropoffStopName,
    this.tripStartTime,
    this.vehicleRegistration,
    this.routeName,
    this.paymentId,
    this.qrCode,
    this.bookingReference,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier.
  final String id;

  /// ID of the passenger.
  final String passengerId;

  /// ID of the trip.
  final String tripId;

  /// Assigned seat number (if seat selection enabled).
  final String? seatNumber;

  /// ID of the pickup stop.
  final String pickupStopId;

  /// ID of the dropoff stop.
  final String dropoffStopId;

  /// Booking amount.
  final double amount;

  /// Currency for the amount.
  final Currency currency;

  /// Booking status.
  final BookingStatus status;

  /// Passenger name (for display).
  final String? passengerName;

  /// Passenger phone (for contact).
  final String? passengerPhone;

  /// Pickup stop name (for display).
  final String? pickupStopName;

  /// Dropoff stop name (for display).
  final String? dropoffStopName;

  /// Trip start time (for display).
  final DateTime? tripStartTime;

  /// Vehicle registration (for display).
  final String? vehicleRegistration;

  /// Route name (for display).
  final String? routeName;

  /// ID of the associated payment.
  final String? paymentId;

  /// QR code data for boarding.
  final String? qrCode;

  /// Human-readable booking reference.
  final String? bookingReference;

  /// When the booking was created.
  final DateTime? createdAt;

  /// When the booking was last updated.
  final DateTime? updatedAt;

  /// Whether the booking is pending.
  bool get isPending => status == BookingStatus.pending;

  /// Whether the booking is confirmed.
  bool get isConfirmed => status == BookingStatus.confirmed;

  /// Whether the booking is cancelled.
  bool get isCancelled => status == BookingStatus.cancelled;

  /// Whether the booking is completed.
  bool get isCompleted => status == BookingStatus.completed;

  /// Whether the booking can be cancelled.
  bool get canCancel => status.canCancel;

  /// Whether the booking has a seat assigned.
  bool get hasSeat => seatNumber != null;

  /// Whether the booking has a QR code.
  bool get hasQrCode => qrCode != null;

  /// Format the amount with currency.
  String get formattedAmount => currency.format(amount);

  /// Creates a copy with modified fields.
  Booking copyWith({
    String? id,
    String? passengerId,
    String? tripId,
    String? seatNumber,
    String? pickupStopId,
    String? dropoffStopId,
    double? amount,
    Currency? currency,
    BookingStatus? status,
    String? passengerName,
    String? passengerPhone,
    String? pickupStopName,
    String? dropoffStopName,
    DateTime? tripStartTime,
    String? vehicleRegistration,
    String? routeName,
    String? paymentId,
    String? qrCode,
    String? bookingReference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      tripId: tripId ?? this.tripId,
      seatNumber: seatNumber ?? this.seatNumber,
      pickupStopId: pickupStopId ?? this.pickupStopId,
      dropoffStopId: dropoffStopId ?? this.dropoffStopId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      pickupStopName: pickupStopName ?? this.pickupStopName,
      dropoffStopName: dropoffStopName ?? this.dropoffStopName,
      tripStartTime: tripStartTime ?? this.tripStartTime,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      routeName: routeName ?? this.routeName,
      paymentId: paymentId ?? this.paymentId,
      qrCode: qrCode ?? this.qrCode,
      bookingReference: bookingReference ?? this.bookingReference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        passengerId,
        tripId,
        seatNumber,
        pickupStopId,
        dropoffStopId,
        amount,
        currency,
        status,
        passengerName,
        passengerPhone,
        pickupStopName,
        dropoffStopName,
        tripStartTime,
        vehicleRegistration,
        routeName,
        paymentId,
        qrCode,
        bookingReference,
        createdAt,
        updatedAt,
      ];
}
