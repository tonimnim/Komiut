import 'package:komiut_app/driver/history/data/datasources/history_remote_datasource.dart';
import 'package:komiut_app/driver/history/data/models/trip_history_model.dart';

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
    return {
      'id': tripId,
      'route_name': 'CBD - Kikuyu',
      'start_time': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'end_time': DateTime.now().subtract(const Duration(hours: 1, minutes: 15)).toIso8601String(),
      'passenger_count': 14,
      'earnings': 1200.0,
      'status': 'completed',
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
