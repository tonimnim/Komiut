import 'package:equatable/equatable.dart';
import '../../../../../core/domain/enums/enums.dart';

class Booking extends Equatable {
  final String id;
  final String tripId;
  final String passengerId;
  final String passengerName;
  final String? passengerPhone;
  final BookingStatus status;
  final int seatNumber;
  final String pickupStopName;
  final String dropoffStopName;
  final double amount;
  final bool isPaid;
  final DateTime bookingTime;

  const Booking({
    required this.id,
    required this.tripId,
    required this.passengerId,
    required this.passengerName,
    this.passengerPhone,
    required this.status,
    required this.seatNumber,
    required this.pickupStopName,
    required this.dropoffStopName,
    required this.amount,
    required this.isPaid,
    required this.bookingTime,
  });

  bool get hasSeat => seatNumber > 0;

  @override
  List<Object?> get props => [
        id,
        tripId,
        passengerId,
        passengerName,
        passengerPhone,
        status,
        seatNumber,
        pickupStopName,
        dropoffStopName,
        amount,
        isPaid,
        bookingTime,
      ];
}
