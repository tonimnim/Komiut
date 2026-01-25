/// Create booking request model.
///
/// DTO for creating a new booking via the API.
library;

/// Request model for creating a new booking.
///
/// Contains all the required information to create a booking
/// including trip details, pickup/dropoff stops, and passenger count.
class CreateBookingRequest {
  /// Creates a new CreateBookingRequest.
  const CreateBookingRequest({
    required this.tripId,
    required this.vehicleId,
    required this.pickupStopId,
    required this.dropoffStopId,
    this.seatNumber,
    this.passengerCount = 1,
  });

  /// ID of the trip to book.
  final String tripId;

  /// ID of the vehicle for the trip.
  final String vehicleId;

  /// ID of the stop where passenger will board.
  final String pickupStopId;

  /// ID of the stop where passenger will alight.
  final String dropoffStopId;

  /// Optional seat number selection.
  final int? seatNumber;

  /// Number of passengers (default 1).
  final int passengerCount;

  /// Converts the request to JSON for API submission.
  Map<String, dynamic> toJson() => {
        'tripId': tripId,
        'vehicleId': vehicleId,
        'pickupStopId': pickupStopId,
        'dropoffStopId': dropoffStopId,
        if (seatNumber != null) 'seatNumber': seatNumber,
        'passengerCount': passengerCount,
      };

  /// Creates a copy with modified fields.
  CreateBookingRequest copyWith({
    String? tripId,
    String? vehicleId,
    String? pickupStopId,
    String? dropoffStopId,
    int? seatNumber,
    int? passengerCount,
  }) {
    return CreateBookingRequest(
      tripId: tripId ?? this.tripId,
      vehicleId: vehicleId ?? this.vehicleId,
      pickupStopId: pickupStopId ?? this.pickupStopId,
      dropoffStopId: dropoffStopId ?? this.dropoffStopId,
      seatNumber: seatNumber ?? this.seatNumber,
      passengerCount: passengerCount ?? this.passengerCount,
    );
  }

  @override
  String toString() =>
      'CreateBookingRequest(tripId: $tripId, vehicleId: $vehicleId, '
      'pickupStopId: $pickupStopId, dropoffStopId: $dropoffStopId, '
      'seatNumber: $seatNumber, passengerCount: $passengerCount)';
}

/// Request model for confirming a booking after payment.
class ConfirmBookingRequest {
  /// Creates a new ConfirmBookingRequest.
  const ConfirmBookingRequest({
    required this.paymentId,
  });

  /// ID of the successful payment.
  final String paymentId;

  /// Converts the request to JSON for API submission.
  Map<String, dynamic> toJson() => {
        'paymentId': paymentId,
      };
}
