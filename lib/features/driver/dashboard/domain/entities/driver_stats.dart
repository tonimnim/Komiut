import 'package:equatable/equatable.dart';

/// Represents a driver's statistics summary.
class DriverStats extends Equatable {
  const DriverStats({
    required this.totalTrips,
    required this.totalEarnings,
    required this.totalPassengers,
    this.todayTrips = 0,
    this.todayEarnings = 0.0,
    this.weeklyTrips = 0,
    this.weeklyEarnings = 0.0,
    this.averageRating,
    this.completionRate,
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

  /// Average earnings per trip.
  double get averageEarningsPerTrip =>
      totalTrips > 0 ? totalEarnings / totalTrips : 0;

  /// Average passengers per trip.
  double get averagePassengersPerTrip =>
      totalTrips > 0 ? totalPassengers / totalTrips : 0;

  /// Formatted completion rate for display.
  String get displayCompletionRate =>
      completionRate != null ? '${(completionRate! * 100).toStringAsFixed(0)}%' : 'N/A';

  @override
  List<Object?> get props => [
        totalTrips,
        totalEarnings,
        totalPassengers,
        todayTrips,
        todayEarnings,
        weeklyTrips,
        weeklyEarnings,
        averageRating,
        completionRate,
      ];

  DriverStats copyWith({
    int? totalTrips,
    double? totalEarnings,
    int? totalPassengers,
    int? todayTrips,
    double? todayEarnings,
    int? weeklyTrips,
    double? weeklyEarnings,
    double? averageRating,
    double? completionRate,
  }) {
    return DriverStats(
      totalTrips: totalTrips ?? this.totalTrips,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalPassengers: totalPassengers ?? this.totalPassengers,
      todayTrips: todayTrips ?? this.todayTrips,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      weeklyTrips: weeklyTrips ?? this.weeklyTrips,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      averageRating: averageRating ?? this.averageRating,
      completionRate: completionRate ?? this.completionRate,
    );
  }
}
