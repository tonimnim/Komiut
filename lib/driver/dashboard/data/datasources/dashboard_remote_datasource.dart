import 'package:komiut_app/core/network/api_client.dart';
import 'package:komiut_app/core/config/api_endpoints.dart';
import 'package:komiut_app/driver/dashboard/data/models/dashboard_models.dart';

abstract class DashboardRemoteDataSource {
  Future<DriverProfileModel> getDriverProfile();
  Future<VehicleModel> getVehicle();
  Future<CircleModel> getCircle();
  Future<CircleRouteModel> getRoute();
  Future<String> toggleStatus(String newStatus);
  Future<EarningsSummaryModel> getTodayEarnings();
  Future<List<Map<String, dynamic>>> getNotifications();
  Future<int> getCurrentPassengers();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient _apiClient;

  DashboardRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DriverProfileModel> getDriverProfile() async {
    final response = await _apiClient.get(ApiEndpoints.driverProfile);
    // v2 might return the object directly or wrapped in 'data'
    final data = response.data is Map && response.data.containsKey('data') 
        ? response.data['data'] 
        : (response.data is List ? response.data.first : response.data);
    return DriverProfileModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<VehicleModel> getVehicle() async {
    final response = await _apiClient.get(ApiEndpoints.driverVehicle);
    final data = response.data is Map && response.data.containsKey('data') 
        ? response.data['data'] 
        : (response.data is List ? response.data.first : response.data);
    return VehicleModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<CircleModel> getCircle() async {
    final response = await _apiClient.get(ApiEndpoints.driverCircle);
    final data = response.data is Map && response.data.containsKey('data') 
        ? response.data['data'] 
        : (response.data is List ? response.data.first : response.data);
    return CircleModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<CircleRouteModel> getRoute() async {
    final response = await _apiClient.get(ApiEndpoints.driverRoute);
    final data = response.data is Map && response.data.containsKey('data') 
        ? response.data['data'] 
        : (response.data is List ? response.data.first : response.data);
    return CircleRouteModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<String> toggleStatus(String newStatus) async {
    // v2 uses PUT /api/Personnel for updates
    final profile = await getDriverProfile();
    final response = await _apiClient.put(
      ApiEndpoints.driverProfile,
      data: {
        'id': profile.id,
        'status': newStatus == 'online' ? 1 : 0,
      },
    );
    // Handle potential wrapper or direct return
    final data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
    return (data['status'] == 1 ? 'online' : 'offline');
  }

  @override
  Future<EarningsSummaryModel> getTodayEarnings() async {
    final response = await _apiClient.get(
      ApiEndpoints.earningsSummary,
      queryParameters: {
        'FromDate': DateTime.now().toIso8601String().split('T')[0], // Simplified for today
      },
    );
    final data = response.data is Map && response.data.containsKey('data') 
        ? response.data['data'] 
        : (response.data is List ? response.data.first : response.data);
    return EarningsSummaryModel.fromJson(data as Map<String, dynamic>);
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
  Future<int> getCurrentPassengers() async {
    // This would typically call an API endpoint like ApiEndpoints.currentPassengers
    return 0;
  }
}
