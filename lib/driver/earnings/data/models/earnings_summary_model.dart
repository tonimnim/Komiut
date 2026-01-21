import '../../domain/entities/earnings_summary.dart';

class EarningsSummaryModel extends EarningsSummary {
  const EarningsSummaryModel({
    required super.period,
    required super.totalTrips,
    required super.totalPassengers,
    required super.grossEarnings,
    required super.platformFees,
    required super.netEarnings,
    required super.averagePerTrip,
  });

  factory EarningsSummaryModel.fromJson(Map<String, dynamic> json) {
    return EarningsSummaryModel(
      period: json['period'],
      totalTrips: json['total_trips'],
      totalPassengers: json['total_passengers'],
      grossEarnings: (json['gross_earnings'] as num).toDouble(),
      platformFees: (json['platform_fees'] as num).toDouble(),
      netEarnings: (json['net_earnings'] as num).toDouble(),
      averagePerTrip: (json['average_per_trip'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'total_trips': totalTrips,
      'total_passengers': totalPassengers,
      'gross_earnings': grossEarnings,
      'platform_fees': platformFees,
      'net_earnings': netEarnings,
      'average_per_trip': averagePerTrip,
    };
  }
}
