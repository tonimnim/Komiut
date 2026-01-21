import 'package:equatable/equatable.dart';

class EarningsSummary extends Equatable {
  final String period;
  final int totalTrips;
  final int totalPassengers;
  final double grossEarnings;
  final double platformFees;
  final double netEarnings;
  final double averagePerTrip;

  const EarningsSummary({
    required this.period,
    required this.totalTrips,
    required this.totalPassengers,
    required this.grossEarnings,
    required this.platformFees,
    required this.netEarnings,
    required this.averagePerTrip,
  });

  @override
  List<Object?> get props => [
        period,
        totalTrips,
        totalPassengers,
        grossEarnings,
        platformFees,
        netEarnings,
        averagePerTrip,
      ];
}
