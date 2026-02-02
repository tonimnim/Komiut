import 'package:equatable/equatable.dart';

/// Represents a driver's earnings summary for different time periods.
class EarningsSummary extends Equatable {
  const EarningsSummary({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.allTime,
    this.pendingPayout = 0.0,
    this.lastPayoutAmount,
    this.lastPayoutDate,
    this.currency = 'KES',
  });

  final double today;
  final double thisWeek;
  final double thisMonth;
  final double allTime;
  final double pendingPayout;
  final double? lastPayoutAmount;
  final DateTime? lastPayoutDate;
  final String currency;

  /// Whether there is a pending payout.
  bool get hasPendingPayout => pendingPayout > 0;

  /// Formatted today earnings for display.
  String get displayToday => '$currency ${today.toStringAsFixed(2)}';

  /// Formatted weekly earnings for display.
  String get displayWeekly => '$currency ${thisWeek.toStringAsFixed(2)}';

  /// Formatted monthly earnings for display.
  String get displayMonthly => '$currency ${thisMonth.toStringAsFixed(2)}';

  /// Formatted all-time earnings for display.
  String get displayAllTime => '$currency ${allTime.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        today,
        thisWeek,
        thisMonth,
        allTime,
        pendingPayout,
        lastPayoutAmount,
        lastPayoutDate,
        currency,
      ];

  EarningsSummary copyWith({
    double? today,
    double? thisWeek,
    double? thisMonth,
    double? allTime,
    double? pendingPayout,
    double? lastPayoutAmount,
    DateTime? lastPayoutDate,
    String? currency,
  }) {
    return EarningsSummary(
      today: today ?? this.today,
      thisWeek: thisWeek ?? this.thisWeek,
      thisMonth: thisMonth ?? this.thisMonth,
      allTime: allTime ?? this.allTime,
      pendingPayout: pendingPayout ?? this.pendingPayout,
      lastPayoutAmount: lastPayoutAmount ?? this.lastPayoutAmount,
      lastPayoutDate: lastPayoutDate ?? this.lastPayoutDate,
      currency: currency ?? this.currency,
    );
  }
}
