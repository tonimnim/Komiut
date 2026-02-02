/// Booking API model.
///
/// Data transfer object for booking API responses.
/// Handles JSON serialization/deserialization and entity conversion.
library;

import '../../domain/entities/booking.dart';

/// API model for Booking responses.
///
/// Maps between the API response format and the domain Booking entity.
class BookingModel {
  /// Creates a new BookingModel instance.
  const BookingModel({
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

  /// Creates from JSON map.
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      passengerId: json['passengerId'] as String,
      tripId: json['tripId'] as String,
      vehicleId: json['vehicleId'] as String,
      routeId: json['routeId'] as String,
      seatNumber: json['seatNumber'] as int?,
      pickupStopId: json['pickupStopId'] as String,
      dropoffStopId: json['dropoffStopId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KES',
      status: _parseStatus(json['status'] as String?),
      paymentId: json['paymentId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  /// Parse status string to enum.
  static BookingStatus _parseStatus(String? status) {
    if (status == null) return BookingStatus.pending;
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
      case 'canceled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      case 'expired':
        return BookingStatus.expired;
      default:
        return BookingStatus.pending;
    }
  }

  /// Unique identifier.
  final String id;

  /// Passenger ID.
  final String passengerId;

  /// Trip ID.
  final String tripId;

  /// Vehicle ID.
  final String vehicleId;

  /// Route ID.
  final String routeId;

  /// Seat number (optional).
  final int? seatNumber;

  /// Pickup stop ID.
  final String pickupStopId;

  /// Dropoff stop ID.
  final String dropoffStopId;

  /// Booking amount.
  final double amount;

  /// Currency code.
  final String currency;

  /// Booking status.
  final BookingStatus status;

  /// Payment ID (if paid).
  final String? paymentId;

  /// Created timestamp.
  final DateTime createdAt;

  /// Confirmed timestamp.
  final DateTime? confirmedAt;

  /// Expiry timestamp.
  final DateTime? expiresAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'passengerId': passengerId,
        'tripId': tripId,
        'vehicleId': vehicleId,
        'routeId': routeId,
        if (seatNumber != null) 'seatNumber': seatNumber,
        'pickupStopId': pickupStopId,
        'dropoffStopId': dropoffStopId,
        'amount': amount,
        'currency': currency,
        'status': status.name,
        if (paymentId != null) 'paymentId': paymentId,
        'createdAt': createdAt.toIso8601String(),
        if (confirmedAt != null) 'confirmedAt': confirmedAt!.toIso8601String(),
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  Booking toEntity() {
    return Booking(
      id: id,
      passengerId: passengerId,
      tripId: tripId,
      vehicleId: vehicleId,
      routeId: routeId,
      seatNumber: seatNumber,
      pickupStopId: pickupStopId,
      dropoffStopId: dropoffStopId,
      amount: amount,
      currency: currency,
      status: status,
      paymentId: paymentId,
      createdAt: createdAt,
      confirmedAt: confirmedAt,
      expiresAt: expiresAt,
    );
  }

  /// Creates from domain entity.
  factory BookingModel.fromEntity(Booking entity) {
    return BookingModel(
      id: entity.id,
      passengerId: entity.passengerId,
      tripId: entity.tripId,
      vehicleId: entity.vehicleId,
      routeId: entity.routeId,
      seatNumber: entity.seatNumber,
      pickupStopId: entity.pickupStopId,
      dropoffStopId: entity.dropoffStopId,
      amount: entity.amount,
      currency: entity.currency,
      status: entity.status,
      paymentId: entity.paymentId,
      createdAt: entity.createdAt,
      confirmedAt: entity.confirmedAt,
      expiresAt: entity.expiresAt,
    );
  }

  @override
  String toString() =>
      'BookingModel(id: $id, tripId: $tripId, status: $status)';
}
