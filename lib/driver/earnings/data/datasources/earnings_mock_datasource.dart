import 'package:komiut/driver/earnings/data/datasources/earnings_remote_datasource.dart';
import 'package:komiut/driver/earnings/data/models/earnings_model.dart';
import 'package:komiut/driver/earnings/data/models/earnings_summary_model.dart';

class EarningsMockDataSource implements EarningsRemoteDataSource {
  @override
  Future<EarningsSummaryModel> getEarningsSummary({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Mock data based on period
    if (period == 'daily') {
      return EarningsSummaryModel(
        period: period,
        totalTrips: 12,
        totalPassengers: 112,
        grossEarnings: 5200.00,
        platformFees: 520.00,
        netEarnings: 4680.00,
        averagePerTrip: 433.33,
      );
    }
    
    // Default to weekly/monthly
    return EarningsSummaryModel(
      period: period,
      totalTrips: 142,
      totalPassengers: 1136,
      grossEarnings: 34500.00,
      platformFees: 3450.00,
      netEarnings: 31050.00,
      averagePerTrip: 242.95,
    );
  }

  @override
  Future<EarningsModel> getTripEarnings(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return EarningsModel(
      tripId: tripId,
      routeName: 'CBD - Kikuyu',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      passengerCount: 14,
      farePerPassenger: 100.0,
      grossFare: 1400.0,
      platformFeePercent: 10.0,
      platformFee: 140.0,
      netEarnings: 1260.0,
    );
  }
}
