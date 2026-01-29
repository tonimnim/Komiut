import 'package:komiut/driver/trip/data/datasources/trip_remote_datasource.dart';
import 'package:komiut/driver/trip/data/models/trip_model.dart';
import 'package:komiut/driver/dashboard/data/models/dashboard_models.dart';
import 'package:komiut/driver/trip/domain/entities/trip.dart';
import 'package:komiut/driver/dashboard/data/datasources/dashboard_mock_datasource.dart';

class TripMockDataSource implements TripRemoteDataSource {
  TripModel? _currentTrip;

  final _mockRoute = CircleRouteModel(
    id: 'mock-route-123',
    name: 'CBD - Kikuyu',
    code: '102',
    status: 'active',
    organizationId: 'mock-org-123',
    createdAt: DateTime.now().subtract(const Duration(days: 100)),
  );

  @override
  Future<TripModel> startTrip(String routeId, String vehicleId) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentTrip = TripModel(
      id: 'mock-trip-123',
      route: _mockRoute,
      status: TripStatus.started,
      currentPassengerCount: 8,
      currentEarnings: 800.0,
      scheduledTime: DateTime.now(),
    );

    DashboardMockDataSource.addNotification(
      'Trip Started',
      'Your trip to ${_mockRoute.name} has started successfully.',
      'trip',
    );
    
    return _currentTrip!;
  }

  @override
  Future<TripModel> updateTripStatus(String tripId, String status, {Map<String, dynamic>? data}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return TripModel(
      id: tripId,
      route: _mockRoute,
      status: _mapStringToStatus(status),
      currentPassengerCount: data?['passenger_count'] ?? 8,
      currentEarnings: data?['earnings'] ?? 450.0,
      scheduledTime: DateTime.now().subtract(const Duration(minutes: 15)),
    );
  }

  @override
  Future<TripModel> endTrip(String tripId, {required int finalPassengers, required double finalEarnings}) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Update dashboard stats
    DashboardMockDataSource.addTrip(finalEarnings);

    DashboardMockDataSource.addNotification(
      'Trip Completed',
      'Trip ended. Earnings: KES ${finalEarnings.toStringAsFixed(0)}',
      'payment',
    );

    final trip = TripModel(
      id: tripId,
      route: _mockRoute,
      status: TripStatus.completed,
      currentPassengerCount: finalPassengers,
      currentEarnings: finalEarnings,
      scheduledTime: DateTime.now().subtract(const Duration(minutes: 45)),
    );
    _currentTrip = null;
    return trip;
  }

  @override
  Future<TripModel?> getActiveTrip() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentTrip;
  }

  @override
  Future<TripModel> getTripById(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return TripModel(
      id: tripId,
      route: _mockRoute,
      status: TripStatus.completed,
      currentPassengerCount: 14,
      currentEarnings: 1200.0,
      scheduledTime: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  TripStatus _mapStringToStatus(String status) {
    switch (status) {
      case 'started': return TripStatus.started;
      case 'in_progress': return TripStatus.inProgress;
      case 'completed': return TripStatus.completed;
      default: return TripStatus.scheduled;
    }
  }
}
