import 'package:komiut/core/network/api_client.dart';
import 'package:komiut/core/network/api_endpoints.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';
import 'package:komiut/driver/dashboard/data/models/dashboard_models.dart';
import 'package:komiut/core/errors/failures.dart';

abstract class DashboardRemoteDataSource {
  Future<DriverProfileModel> getDriverProfile();
  Future<VehicleModel> getVehicle();
  Future<CircleModel> getCircle();
  Future<CircleRouteModel> getRoute();
  Future<String> toggleStatus(String newStatus);
  Future<EarningsSummaryModel> getTodayEarnings();
  Future<List<Map<String, dynamic>>> getNotifications();
  Future<void> markNotificationAsRead(String id);
  Future<int> getCurrentPassengers();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient _apiClient;

  DashboardRemoteDataSourceImpl(this._apiClient);

  Future<T> _unwrap<T>(Future<dynamic> request) async {
    final result = await request;
    return result.fold(
      (failure) => throw ServerFailure(failure.message),
      (data) => data as T,
    );
  }

  @override
  Future<DriverProfileModel> getDriverProfile() async {
    final response = await _apiClient.getDriver(ApiEndpoints.personnelMy);
    final data = response.data;
    final processedData = data is Map && data.containsKey('data') 
        ? data['data'] 
        : (data is List ? data.first : data);
    return DriverProfileModel.fromJson(processedData as Map<String, dynamic>);
  }

  @override
  Future<VehicleModel> getVehicle() async {
    final response = await _apiClient.getDriver(ApiEndpoints.vehicleMyDriver); // Use specific endpoint if available, or vehicles
    // ApiEndpoints.vehicles is base. Legacy used vehicles.
    // If getVehicle() implies "MY vehicle", we should use vehicleMyDriver from new endpoints.
    final data = response.data;
    final processedData = data is Map && data.containsKey('data') 
        ? data['data'] 
        : (data is List ? data.first : data);
    return VehicleModel.fromJson(processedData as Map<String, dynamic>);
  }

  @override
  Future<CircleModel> getCircle() async {
    // Legacy used domains. Network has domains.
    // Assuming GET /api/Domains returns list, and we pick first?
    final response = await _apiClient.getDriver(ApiEndpoints.domains);
    final data = response.data;
    final processedData = data is Map && data.containsKey('data') 
        ? data['data'] 
        : (data is List ? data.first : data);
    return CircleModel.fromJson(processedData as Map<String, dynamic>);
  }

  @override
  Future<CircleRouteModel> getRoute() async {
    final response = await _apiClient.getDriver(ApiEndpoints.routes);
    final data = response.data;
    final processedData = data is Map && data.containsKey('data') 
        ? data['data'] 
        : (data is List ? data.first : data);
    return CircleRouteModel.fromJson(processedData as Map<String, dynamic>);
  }

  @override
  Future<String> toggleStatus(String newStatus) async {
    final profile = await getDriverProfile();
    final response = await _apiClient.putDriver(
      ApiEndpoints.personnel,
      data: {
        'id': profile.id,
        'status': newStatus == 'online' ? 1 : 0,
      },
    );
    final data = response.data;
    final processedData = data is Map && data.containsKey('data') ? data['data'] : data;
    return (processedData['status'] == 1 ? 'online' : 'offline');
  }

  @override
  Future<EarningsSummaryModel> getTodayEarnings() async {
    // For now, return a mock with some values if API returns empty
    try {
      final response = await _apiClient.getDriver(
        ApiEndpoints.dailyVehicleTotals,
        queryParameters: {
          'FromDate': DateTime.now().toIso8601String().split('T')[0],
        },
      );
      final data = response.data;
      final processedData = data is Map && data.containsKey('data') 
          ? data['data'] 
          : (data is List ? (data.isNotEmpty ? data.first : null) : data);
          
      if (processedData == null) {
        return const EarningsSummaryModel(tripCount: 8, totalEarnings: 4200);
      }
      return EarningsSummaryModel.fromJson(processedData as Map<String, dynamic>);
    } catch (e) {
      return const EarningsSummaryModel(tripCount: 8, totalEarnings: 4200);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    return [
      {
        'id': '1',
        'type': 'payment',
        'title': 'Payment Received',
        'message': 'You have received KES 1,200 for your last trip.',
        'time': '2 mins ago',
        'isRead': false,
      },
      {
        'id': '2',
        'type': 'status',
        'title': 'System Update',
        'message': 'App update v2.1 is now available for download.',
        'time': '1 hour ago',
        'isRead': false,
      },
      {
        'id': '3',
        'type': 'stage',
        'title': 'New Route Assigned',
        'message': 'You have been assigned the Nairobi CBD - Westlands route.',
        'time': '3 hours ago',
        'isRead': true,
      },
      {
        'id': '4',
        'type': 'payment',
        'title': 'Weekly Bonus',
        'message': 'Congratulations! You earned a KES 500 bonus for 50 trips.',
        'time': 'Yesterday',
        'isRead': true,
      },
    ];
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    // Stub
  }

  @override
  Future<int> getCurrentPassengers() async {
    // Mocking a loading state with 10 passengers for a 14-seater
    return 10;
  }
}
