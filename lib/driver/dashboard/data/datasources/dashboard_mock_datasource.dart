import 'package:komiut/driver/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:komiut/driver/dashboard/data/models/dashboard_models.dart';

class DashboardMockDataSource implements DashboardRemoteDataSource {
  @override
  Future<DriverProfileModel> getDriverProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DriverProfileModel(
      id: 'mock-driver-123',
      organizationId: 'mock-org-123',
      name: 'Musa Mwange',
      email: 'musa@komiut.com',
      phone: '+254114945842',
      status: 1, // Active
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  @override
  Future<VehicleModel> getVehicle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return VehicleModel(
      id: 'mock-vehicle-123',
      registrationNumber: const RegistrationNumberModel(value: 'KBD 123X'),
      capacity: 14,
      status: 'active',
      currentRouteId: 'mock-route-123',
      organizationId: 'mock-org-123',
      domainId: 'mock-domain-123',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      model: 'Toyota Hiace',
      year: 2020,
      color: 'White',
      type: 'Matatu',
      insuranceExpiry: DateTime.now().add(const Duration(days: 120)),
      inspectionExpiry: DateTime.now().add(const Duration(days: 45)),
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
      name: 'CBD - Kikuyu',
      code: '102',
      status: 'active',
      organizationId: 'mock-org-123',
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
      circleName: 'Nairobi CBD',
      pickupPoint: 'CBD Stage',
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
        'message': 'Ksh 250 received from Sarah W. for Route 102',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String(),
        'isRead': false,
        'type': 'payment',
      },
      {
        'id': '2',
        'title': 'Stage Approach',
        'message': 'Approaching Uhuru Park stage. 3 passengers waiting.',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
        'isRead': false,
        'type': 'stage',
      },
      {
        'id': '3',
        'title': 'Vehicle Status',
        'message': 'Vehicle is now 80% Full. Prepare for departure.',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 25)).toIso8601String(),
        'isRead': true,
        'type': 'status',
      },
      {
        'id': '4',
        'title': 'Loading Update',
        'message': 'Currently loading passengers at Main Terminal.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'isRead': true,
        'type': 'loading',
      },
    ];
  }

  @override
  Future<int> getCurrentPassengers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 8;
  }
}

