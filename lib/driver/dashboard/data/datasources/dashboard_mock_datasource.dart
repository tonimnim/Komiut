import 'package:komiut_app/driver/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:komiut_app/driver/dashboard/data/models/dashboard_models.dart';

class DashboardMockDataSource implements DashboardRemoteDataSource {
  @override
  Future<DriverProfileModel> getDriverProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const DriverProfileModel(
      id: 'mock-driver-123',
      name: 'Musa Mwange',
      email: 'musa@komiut.com',
      phone: '+254114945842',
      status: 'live',
      profileImage: 'https://i.pravatar.cc/150?u=musa',
      rating: 4.8,
      totalTrips: 156,
    );
  }

  @override
  Future<VehicleModel> getVehicle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const VehicleModel(
      id: 'mock-vehicle-123',
      plateNumber: 'KBD 123X',
      model: 'Toyota Hiace',
      capacity: 14,
      color: 'White',
      type: 'Bus',
      year: 2022,
      status: 'active',
    );
  }

  @override
  Future<CircleModel> getCircle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const CircleModel(
      id: 'mock-circle-123',
      name: 'Super Metro',
      lat: -1.2867,
      lng: 36.8172,
      radiusKm: 5.0,
    );
  }

  @override
  Future<CircleRouteModel> getRoute() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return CircleRouteModel(
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
  }

  @override
  Future<String> toggleStatus(String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return newStatus;
  }

  @override
  Future<EarningsSummaryModel> getTodayEarnings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const EarningsSummaryModel(
      totalEarnings: 4500.0,
      tripCount: 8,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': '1',
        'title': 'Payment Received',
        'message': 'Ksh 150 received from Jane Doe for Route 102',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
        'isRead': false,
        'type': 'payment',
      },
      {
        'id': '2',
        'title': 'System Update',
        'message': 'New security features added to your account.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'isRead': true,
        'type': 'system',
      },
    ];
  }

  @override
  Future<int> getCurrentPassengers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 8; // Showing Loading state
  }
}
