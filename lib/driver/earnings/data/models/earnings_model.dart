import '../../domain/entities/earnings.dart';

class EarningsModel extends Earnings {
  const EarningsModel({
    required super.tripId,
    required super.routeName,
    required super.date,
    required super.passengerCount,
    required super.farePerPassenger,
    required super.grossFare,
    required super.platformFeePercent,
    required super.platformFee,
    required super.netEarnings,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      tripId: json['trip_id'],
      routeName: json['route_name'],
      date: DateTime.parse(json['date']),
      passengerCount: json['passenger_count'],
      farePerPassenger: (json['fare_per_passenger'] as num).toDouble(),
      grossFare: (json['gross_fare'] as num).toDouble(),
      platformFeePercent: (json['platform_fee_percent'] as num).toDouble(),
      platformFee: (json['platform_fee'] as num).toDouble(),
      netEarnings: (json['net_earnings'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'route_name': routeName,
      'date': date.toIso8601String(),
      'passenger_count': passengerCount,
      'fare_per_passenger': farePerPassenger,
      'gross_fare': grossFare,
      'platform_fee_percent': platformFeePercent,
      'platform_fee': platformFee,
      'net_earnings': netEarnings,
    };
  }
}
