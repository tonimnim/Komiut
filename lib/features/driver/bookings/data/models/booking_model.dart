import '../../domain/entities/booking.dart';
import '../../../../../core/domain/enums/enums.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.tripId,
    required super.passengerId,
    required super.passengerName,
    super.passengerPhone,
    required super.status,
    required super.seatNumber,
    required super.pickupStopName,
    required super.dropoffStopName,
    required super.amount,
    required super.isPaid,
    required super.bookingTime,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['bookingId'] as String? ?? json['id'] as String,
      tripId: json['tripId'] as String,
      passengerId: json['passengerId'] as String,
      // API currently does not return names, using placeholders or looking for extended properties
      passengerName: json['passengerName'] as String? ?? 'Passenger',
      passengerPhone: json['passengerPhone'] as String?,
      status: _parseStatus(json['status'] as String?),
      seatNumber: json['seatNumber'] as int? ?? 0,
      pickupStopName:
          json['pickupPointId'] as String? ?? 'Pickup', // TODO: Fetch stop name
      dropoffStopName: json['dropoffPointId'] as String? ??
          'Dropoff', // TODO: Fetch stop name
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isPaid:
          true, // Assuming paid if it exists in this list, or need status check
      bookingTime: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': id,
      'tripId': tripId,
      'passengerId': passengerId,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'status': status.name,
      'seatNumber': seatNumber,
      'pickupPointId': pickupStopName,
      'dropoffPointId': dropoffStopName,
      'amount': amount,
      'createdAt': bookingTime.toIso8601String(),
    };
  }

  static BookingStatus _parseStatus(String? status) {
    if (status == null) return BookingStatus.pending;
    try {
      // Handle numeric status if strictly following enum or string
      // The API spec showed integers for enums in some places but strings in others?
      // Spec says BookingStatus enum [0, 1, 2].
      // But response content example often implies strings in these DTOs unless explicitly integer enum.
      // Dto says: "status": { "type": "string", "nullable": true } in BookingDto properties!
      // But Parameters says "schema": { "$ref": "#/components/schemas/BookingStatus" } which is int.
      // C# often serializes enums as integers by default but can be configured to string.
      // Given the DTO property type is "string", it's likely "Confirmed", "Pending" etc. or "0", "1".

      // Attempt to parse integer first
      final intStatus = int.tryParse(status);
      if (intStatus != null) {
        switch (intStatus) {
          case 1:
            return BookingStatus.confirmed;
          case 2:
            return BookingStatus.completed;
          // 0 or others
          default:
            return BookingStatus.pending;
        }
      }

      return BookingStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == status.toLowerCase(),
        orElse: () => BookingStatus.pending,
      );
    } catch (_) {
      return BookingStatus.pending;
    }
  }
}
