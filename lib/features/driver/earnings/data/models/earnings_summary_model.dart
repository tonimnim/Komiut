import '../../domain/entities/earnings_summary.dart';

/// Data model for earnings summary.
///
/// Aggregates data from:
/// - GET /api/DailyVehicleTotals
/// - GET /api/Payments
class EarningsSummaryModel {
  EarningsSummaryModel({
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

  factory EarningsSummaryModel.fromJson(Map<String, dynamic> json) {
    return EarningsSummaryModel(
      today: (json['today'] as num?)?.toDouble() ?? 0.0,
      thisWeek: (json['thisWeek'] as num?)?.toDouble() ?? 0.0,
      thisMonth: (json['thisMonth'] as num?)?.toDouble() ?? 0.0,
      allTime: (json['allTime'] as num?)?.toDouble() ?? 0.0,
      pendingPayout: (json['pendingPayout'] as num?)?.toDouble() ?? 0.0,
      lastPayoutAmount: (json['lastPayoutAmount'] as num?)?.toDouble(),
      lastPayoutDate: json['lastPayoutDate'] != null
          ? DateTime.tryParse(json['lastPayoutDate'] as String)
          : null,
      currency: json['currency'] as String? ?? 'KES',
    );
  }

  /// Creates from DailyVehicleTotalDto list.
  factory EarningsSummaryModel.fromDailyTotals(List<dynamic> dailyTotals) {
    double today = 0.0;
    double thisWeek = 0.0;
    double thisMonth = 0.0;
    double allTime = 0.0;
    String currency = 'KES';

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekAgo = todayStart.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    for (final total in dailyTotals) {
      final amount = (total['totalCollected'] as num?)?.toDouble() ?? 0.0;
      final dateStr = total['date'] as String?;
      currency = total['currency'] as String? ?? 'KES';

      allTime += amount;

      if (dateStr != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          if (date.year == todayStart.year &&
              date.month == todayStart.month &&
              date.day == todayStart.day) {
            today += amount;
          }
          if (date.isAfter(weekAgo)) {
            thisWeek += amount;
          }
          if (date.isAfter(monthAgo)) {
            thisMonth += amount;
          }
        }
      }
    }

    return EarningsSummaryModel(
      today: today,
      thisWeek: thisWeek,
      thisMonth: thisMonth,
      allTime: allTime,
      currency: currency,
    );
  }

  Map<String, dynamic> toJson() => {
        'today': today,
        'thisWeek': thisWeek,
        'thisMonth': thisMonth,
        'allTime': allTime,
        'pendingPayout': pendingPayout,
        if (lastPayoutAmount != null) 'lastPayoutAmount': lastPayoutAmount,
        if (lastPayoutDate != null)
          'lastPayoutDate': lastPayoutDate!.toIso8601String(),
        'currency': currency,
      };

  EarningsSummary toEntity() => EarningsSummary(
        today: today,
        thisWeek: thisWeek,
        thisMonth: thisMonth,
        allTime: allTime,
        pendingPayout: pendingPayout,
        lastPayoutAmount: lastPayoutAmount,
        lastPayoutDate: lastPayoutDate,
        currency: currency,
      );
}
