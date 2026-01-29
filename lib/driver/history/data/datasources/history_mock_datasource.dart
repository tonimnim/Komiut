import 'package:komiut/driver/history/data/datasources/history_remote_datasource.dart';
import 'package:komiut/driver/history/data/models/trip_history_model.dart';

class HistoryMockDataSource implements HistoryRemoteDataSource {
  @override
  Future<List<TripHistoryModel>> getTripHistory({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? routeId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      TripHistoryModel(
        tripId: '1',
        routeName: 'CBD - Kikuyu',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        time: '10:30 AM',
        passengers: 14,
        earnings: 1200.0,
        status: 'completed',
      ),
      TripHistoryModel(
        tripId: '2',
        routeName: 'CBD - Kikuyu',
        date: DateTime.now().subtract(const Duration(hours: 5)),
        time: '08:30 AM',
        passengers: 12,
        earnings: 1050.0,
        status: 'completed',
      ),
      TripHistoryModel(
        tripId: '3',
        routeName: 'CBD - Kikuyu',
        date: DateTime.now().subtract(const Duration(days: 1)),
        time: '10:30 AM',
        passengers: 14,
        earnings: 1200.0,
        status: 'completed',
      ),
    ];
  }

  @override
  Future<dynamic> getTripHistoryDetails(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    return {
      'trip_id': tripId,
      'status': 'completed',
      'started_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
      'ended_at': now.subtract(const Duration(hours: 1, minutes: 15)).toIso8601String(),
      'duration_mins': 45,
      'distance_km': 15.5,
      'passenger_count': 14,
      'route': {
        'name': 'CBD - Kikuyu',
        'id': 'route-123',
      },
      'earnings': {
        'gross_fare': 1400.0,
        'platform_fee': 140.0,
        'net_earnings': 1260.0,
      },
      'stops': [
        {'name': 'Kikuyu Stage', 'time': '14:00', 'passengers_in': 14, 'passengers_out': 0},
        {'name': 'Uthiru', 'time': '14:15', 'passengers_in': 0, 'passengers_out': 2},
        {'name': 'Kangemi', 'time': '14:25', 'passengers_in': 2, 'passengers_out': 1},
        {'name': 'Westlands', 'time': '14:40', 'passengers_in': 0, 'passengers_out': 5},
        {'name': 'CBD Terminal', 'time': '14:55', 'passengers_in': 0, 'passengers_out': 10},
      ],
    };
  }
}
