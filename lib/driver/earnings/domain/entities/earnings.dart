import 'package:equatable/equatable.dart';

class Earnings extends Equatable {
  final String tripId;
  final String routeName;
  final DateTime date;
  final int passengerCount;
  final double farePerPassenger;
  final double grossFare;
  final double platformFeePercent;
  final double platformFee;
  final double netEarnings;

  const Earnings({
    required this.tripId,
    required this.routeName,
    required this.date,
    required this.passengerCount,
    required this.farePerPassenger,
    required this.grossFare,
    required this.platformFeePercent,
    required this.platformFee,
    required this.netEarnings,
  });

  @override
  List<Object?> get props => [
        tripId,
        routeName,
        date,
        passengerCount,
        farePerPassenger,
        grossFare,
        platformFeePercent,
        platformFee,
        netEarnings,
      ];
}
