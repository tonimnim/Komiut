import 'package:komiut_app/driver/trip/data/datasources/trip_remote_datasource.dart';
import 'package:komiut_app/driver/trip/data/models/trip_model.dart';
import 'package:komiut_app/driver/dashboard/data/models/dashboard_models.dart';
import 'package:komiut_app/driver/trip/domain/entities/trip.dart';

class TripMockDataSource implements TripRemoteDataSource {
  TripModel? _currentTrip;

  final _mockRoute = CircleRouteModel(
    id: 'mock-route-123',
    number: '102',
    name: 'CBD - Kikuyu',
    circleId: 'mock-circle-123',
    startPoint: const RoutePointModel(name: 'Kikuyu', lat: -1.24, lng: 36.67),
    endPoint: const RoutePointModel(name: 'CBD', lat: -1.28, lng: 36.82),
    stops: const [],
    fare: 100.0,
    estimatedDurationMins: 45,
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
