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
    final data = response.data['data'] as Map<String, dynamic>;
    return DriverProfileModel.fromJson(data);
  }

  @override
  Future<VehicleModel> getVehicle() async {
    final response = await _apiClient.get(ApiEndpoints.driverVehicle);
    final data = response.data['data'] as Map<String, dynamic>;
    return VehicleModel.fromJson(data);
  }

  @override
  Future<CircleModel> getCircle() async {
    final response = await _apiClient.get(ApiEndpoints.driverCircle);
    final data = response.data['data'] as Map<String, dynamic>;
    return CircleModel.fromJson(data);
  }

  @override
  Future<CircleRouteModel> getRoute() async {
    final response = await _apiClient.get(ApiEndpoints.driverRoute);
    final data = response.data['data'] as Map<String, dynamic>;
    return CircleRouteModel.fromJson(data);
  }

  @override
  Future<String> toggleStatus(String newStatus) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverStatus,
      data: {'status': newStatus},
    );
    return response.data['data']['status'] as String;
  }

  @override
  Future<EarningsSummaryModel> getTodayEarnings() async {
    final response = await _apiClient.get(
      ApiEndpoints.earningsSummary,
      queryParameters: {'period': 'today'},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return EarningsSummaryModel.fromJson(data);
  }

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    // This would typically call an API endpoint like ApiEndpoints.notifications
    // For now, we return an empty list or throw if not implemented
    return [];
  }

  @override
  Future<int> getCurrentPassengers() async {
    // This would typically call an API endpoint like ApiEndpoints.currentPassengers
    return 0;
  }
}
