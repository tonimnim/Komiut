/// Booking API model.
///
/// Data transfer object for Booking entity matching API schema.
library;

import '../../domain/entities/booking.dart';
import '../../domain/enums/enums.dart';

/// Booking model for API communication.
class BookingModel {
  /// Creates a new BookingModel instance.
  const BookingModel({
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

  /// Creates from JSON map.
  /// Handles both 'bookingId' (Swagger schema) and 'id' field names.
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['bookingId'] as String? ?? json['id'] as String,
      passengerId: json['passengerId'] as String,
      tripId: json['tripId'] as String,
      seatNumber: json['seatNumber'] as String?,
      pickupStopId:
          json['pickupPointId'] as String? ?? json['pickupStopId'] as String,
      dropoffStopId:
          json['dropoffPointId'] as String? ?? json['dropoffStopId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: currencyFromString(json['currency'] as String? ?? 'KES'),
      status: _parseBookingStatus(json['status']),
      passengerName: json['passengerName'] as String?,
      passengerPhone: json['passengerPhone'] as String?,
      pickupStopName: json['pickupStopName'] as String?,
      dropoffStopName: json['dropoffStopName'] as String?,
      tripStartTime: json['tripStartTime'] != null
          ? DateTime.parse(json['tripStartTime'] as String)
          : null,
      vehicleRegistration: json['vehicleRegistration'] as String?,
      routeName: json['routeName'] as String?,
      paymentId: json['paymentId'] as String?,
      qrCode: json['qrCode'] as String?,
      bookingReference: json['bookingReference'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Creates from entity.
  factory BookingModel.fromEntity(Booking entity) {
    return BookingModel(
      id: entity.id,
      passengerId: entity.passengerId,
      tripId: entity.tripId,
      seatNumber: entity.seatNumber,
      pickupStopId: entity.pickupStopId,
      dropoffStopId: entity.dropoffStopId,
      amount: entity.amount,
      currency: entity.currency,
      status: entity.status,
      passengerName: entity.passengerName,
      passengerPhone: entity.passengerPhone,
      pickupStopName: entity.pickupStopName,
      dropoffStopName: entity.dropoffStopName,
      tripStartTime: entity.tripStartTime,
      vehicleRegistration: entity.vehicleRegistration,
      routeName: entity.routeName,
      paymentId: entity.paymentId,
      qrCode: entity.qrCode,
      bookingReference: entity.bookingReference,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String passengerId;
  final String tripId;
  final String? seatNumber;
  final String pickupStopId;
  final String dropoffStopId;
  final double amount;
  final Currency currency;
  final BookingStatus status;
  final String? passengerName;
  final String? passengerPhone;
  final String? pickupStopName;
  final String? dropoffStopName;
  final DateTime? tripStartTime;
  final String? vehicleRegistration;
  final String? routeName;
  final String? paymentId;
  final String? qrCode;
  final String? bookingReference;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'passengerId': passengerId,
        'tripId': tripId,
        if (seatNumber != null) 'seatNumber': seatNumber,
        'pickupPointId': pickupStopId,
        'dropoffPointId': dropoffStopId,
        'amount': amount,
        'currency': currency.name,
        'status': status.toApiValue(),
        if (passengerName != null) 'passengerName': passengerName,
        if (passengerPhone != null) 'passengerPhone': passengerPhone,
        if (pickupStopName != null) 'pickupStopName': pickupStopName,
        if (dropoffStopName != null) 'dropoffStopName': dropoffStopName,
        if (tripStartTime != null)
          'tripStartTime': tripStartTime!.toIso8601String(),
        if (vehicleRegistration != null)
          'vehicleRegistration': vehicleRegistration,
        if (routeName != null) 'routeName': routeName,
        if (paymentId != null) 'paymentId': paymentId,
        if (qrCode != null) 'qrCode': qrCode,
        if (bookingReference != null) 'bookingReference': bookingReference,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Converts to domain entity.
  Booking toEntity() => Booking(
        id: id,
        passengerId: passengerId,
        tripId: tripId,
        seatNumber: seatNumber,
        pickupStopId: pickupStopId,
        dropoffStopId: dropoffStopId,
        amount: amount,
        currency: currency,
        status: status,
        passengerName: passengerName,
        passengerPhone: passengerPhone,
        pickupStopName: pickupStopName,
        dropoffStopName: dropoffStopName,
        tripStartTime: tripStartTime,
        vehicleRegistration: vehicleRegistration,
        routeName: routeName,
        paymentId: paymentId,
        qrCode: qrCode,
        bookingReference: bookingReference,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

/// Helper to parse booking status from int or string.
BookingStatus _parseBookingStatus(dynamic status) {
  if (status is int) {
    // API returns: 0=pending, 1=confirmed, 2=cancelled
    return BookingStatus
        .values[status.clamp(0, BookingStatus.values.length - 1)];
  }
  return bookingStatusFromString(status as String? ?? 'pending');
}
