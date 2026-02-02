import '../../domain/entities/driver_stats.dart';

/// Data model for driver statistics from API.
///
/// Aggregates data from multiple endpoints:
/// - GET /api/DailyVehicleTotals (earnings)
/// - GET /api/Trips (trip counts)
class DriverStatsModel {
  DriverStatsModel({
    required this.totalTrips,
    required this.totalEarnings,
    required this.totalPassengers,
    this.todayTrips = 0,
    this.todayEarnings = 0.0,
    this.weeklyTrips = 0,
    this.weeklyEarnings = 0.0,
    this.averageRating,
    this.completionRate,
    this.currency = 'KES',
  });

  final int totalTrips;
  final double totalEarnings;
  final int totalPassengers;
  final int todayTrips;
  final double todayEarnings;
  final int weeklyTrips;
  final double weeklyEarnings;
  final double? averageRating;
  final double? completionRate;
  final String currency;

  /// Creates model from aggregated API data.
  ///
  /// Combines DailyVehicleTotalDto[] and TripDto[] data.
  factory DriverStatsModel.fromJson(Map<String, dynamic> json) {
    return DriverStatsModel(
      totalTrips: json['totalTrips'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalPassengers: json['totalPassengers'] as int? ?? 0,
      todayTrips: json['todayTrips'] as int? ?? 0,
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      weeklyTrips: json['weeklyTrips'] as int? ?? 0,
      weeklyEarnings: (json['weeklyEarnings'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      completionRate: (json['completionRate'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'KES',
    );
  }

  /// Creates from DailyVehicleTotalDto list.
  factory DriverStatsModel.fromDailyTotals(List<dynamic> dailyTotals) {
    double totalEarnings = 0.0;
    double todayEarnings = 0.0;
    double weeklyEarnings = 0.0;
    String currency = 'KES';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    for (final total in dailyTotals) {
      final amount = (total['totalCollected'] as num?)?.toDouble() ?? 0.0;
      final dateStr = total['date'] as String?;
      currency = total['currency'] as String? ?? 'KES';

      totalEarnings += amount;

      if (dateStr != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          if (date.isAfter(today) || date.isAtSameMomentAs(today)) {
            todayEarnings += amount;
          }
          if (date.isAfter(weekAgo)) {
            weeklyEarnings += amount;
          }
        }
      }
    }

    return DriverStatsModel(
      totalTrips: 0,
      totalEarnings: totalEarnings,
      totalPassengers: 0,
      todayEarnings: todayEarnings,
      weeklyEarnings: weeklyEarnings,
      currency: currency,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalTrips': totalTrips,
        'totalEarnings': totalEarnings,
        'totalPassengers': totalPassengers,
        'todayTrips': todayTrips,
        'todayEarnings': todayEarnings,
        'weeklyTrips': weeklyTrips,
        'weeklyEarnings': weeklyEarnings,
        if (averageRating != null) 'averageRating': averageRating,
        if (completionRate != null) 'completionRate': completionRate,
        'currency': currency,
      };

  DriverStats toEntity() => DriverStats(
        totalTrips: totalTrips,
        totalEarnings: totalEarnings,
        totalPassengers: totalPassengers,
        todayTrips: todayTrips,
        todayEarnings: todayEarnings,
        weeklyTrips: weeklyTrips,
        weeklyEarnings: weeklyEarnings,
        averageRating: averageRating,
        completionRate: completionRate,
      );
}
