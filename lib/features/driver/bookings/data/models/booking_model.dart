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
    final status = _parseStatus(json['status']);
    return BookingModel(
      id: json['bookingId'] as String? ?? json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      passengerId: json['passengerId'] as String? ?? '',
      passengerName: json['passengerName'] as String? ?? 'Passenger',
      passengerPhone: json['passengerPhone'] as String?,
      status: status,
      seatNumber: json['seatNumber'] as int? ?? 0,
      pickupStopName: json['pickupPointId'] as String? ?? 'Pickup',
      dropoffStopName: json['dropoffPointId'] as String? ?? 'Dropoff',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isPaid: status == BookingStatus.confirmed || status == BookingStatus.completed,
      bookingTime: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
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

  static BookingStatus _parseStatus(dynamic status) {
    if (status == null) return BookingStatus.pending;

    // Handle integer status (backend spec: 0=Pending, 1=Confirmed, 2=Cancelled)
    if (status is int) {
      switch (status) {
        case 0:
          return BookingStatus.pending;
        case 1:
          return BookingStatus.confirmed;
        case 2:
          return BookingStatus.cancelled;
        default:
          return BookingStatus.pending;
      }
    }

    final statusStr = status.toString();
    final intStatus = int.tryParse(statusStr);
    if (intStatus != null) {
      switch (intStatus) {
        case 0:
          return BookingStatus.pending;
        case 1:
          return BookingStatus.confirmed;
        case 2:
          return BookingStatus.cancelled;
        default:
          return BookingStatus.pending;
      }
    }

    return BookingStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == statusStr.toLowerCase(),
      orElse: () => BookingStatus.pending,
    );
  }
}
