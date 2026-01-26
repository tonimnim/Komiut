import 'package:komiut/core/network/api_client.dart';
import 'package:komiut/core/config/api_endpoints.dart';
import 'package:komiut/driver/dashboard/data/models/dashboard_models.dart';
import 'package:komiut/core/errors/failures.dart';
import 'package:komiut/core/network/api_exceptions.dart';

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

  Future<T> _unwrap<T>(Future<dynamic> request) async {
    final result = await request;
    return result.fold(
      (failure) => throw ServerFailure(failure.message),
      (data) => data as T,
    );
  }

  @override
  Future<DriverProfileModel> getDriverProfile() async {
    final data = await _unwrap<dynamic>(_apiClient.getDriver(ApiEndpoints.driverProfile));
    final processedData = data is Map && data.containsKey('data') 
        ? data['data'] 
        : (data is List ? data.first : data);
    return DriverProfileModel.fromJson(processedData as Map<String, dynamic>);
  }

  @override
  Future<VehicleModel> getVehicle() async {
    final data = await _unwrap<dynamic>(_apiClient.getDriver(ApiEndpoints.driverVehicle));
    final processedData = data is Map && data.containsKey('data') 
        ? data['data'] 
        : (data is List ? data.first : data);
    return VehicleModel.fromJson(processedData as Map<String, dynamic>);
  }

  @override
  Future<CircleModel> getCircle() async {
    final data = await _unwrap<dynamic>(_apiClient.getDriver(ApiEndpoints.driverCircle));
    final processedData = data is Map && data.containsKey('data') 
        ? data['data'] 
        : (data is List ? data.first : data);
    return CircleModel.fromJson(processedData as Map<String, dynamic>);
  }

  @override
  Future<CircleRouteModel> getRoute() async {
    final data = await _unwrap<dynamic>(_apiClient.getDriver(ApiEndpoints.driverRoute));
    final processedData = data is Map && data.containsKey('data') 
        ? data['data'] 
        : (data is List ? data.first : data);
    return CircleRouteModel.fromJson(processedData as Map<String, dynamic>);
  }

  @override
  Future<String> toggleStatus(String newStatus) async {
    final profile = await getDriverProfile();
    final data = await _unwrap<dynamic>(_apiClient.putDriver(
      ApiEndpoints.driverProfile,
      data: {
        'id': profile.id,
        'status': newStatus == 'online' ? 1 : 0,
      },
    ));
    final processedData = data is Map && data.containsKey('data') ? data['data'] : data;
    return (processedData['status'] == 1 ? 'online' : 'offline');
  }

  @override
  Future<EarningsSummaryModel> getTodayEarnings() async {
    final data = await _unwrap<dynamic>(_apiClient.getDriver(
      ApiEndpoints.earningsSummary,
      queryParameters: {
        'FromDate': DateTime.now().toIso8601String().split('T')[0],
      },
    ));
    final processedData = data is Map && data.containsKey('data') 
        ? data['data'] 
        : (data is List ? data.first : data);
    return EarningsSummaryModel.fromJson(processedData as Map<String, dynamic>);
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
