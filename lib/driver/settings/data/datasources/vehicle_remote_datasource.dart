import 'package:dio/dio.dart';
import 'package:komiut/core/config/api_endpoints.dart';
import 'package:komiut/core/network/api_client.dart';
import 'package:komiut/core/network/api_exceptions.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart';

abstract class VehicleRemoteDataSource {
  Future<Vehicle> getVehicleMyDriver();
  Future<Vehicle> getVehicleById(String id);
  Future<void> assignRoute(String vehicleId, String routeId);
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final ApiClient apiClient;

  VehicleRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Vehicle> getVehicleMyDriver() async {
    try {
      final response = await apiClient.getDriver(
        ApiEndpoints.vehicleMyDriver,
      );
      final data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      // Note: Data from backend might miss 'model', 'color' etc found in local entity.
      return _mapToVehicle(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Vehicle> getVehicleById(String id) async {
    try {
      final response = await apiClient.getDriver(
        ApiEndpoints.vehicleById(id),
      );
      final data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      return _mapToVehicle(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> assignRoute(String vehicleId, String routeId) async {
    try {
      await apiClient.postDriver(
        ApiEndpoints.assignRoute,
        data: {
          'vehicleId': vehicleId,
          'routeId': routeId,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Vehicle _mapToVehicle(Map<String, dynamic> data) {
    // Map backend response to Vehicle Entity
    // Handling missing legacy fields gracefully
    return Vehicle(
      id: data['id'] ?? '',
      registrationNumber: RegistrationNumber(value: data['registrationNumber']?['value'] ?? data['registrationNumber'] ?? ''),
      capacity: data['capacity'] ?? 0,
      status: data['status']?.toString() ?? '0',
      organizationId: data['organizationId'] ?? '',
      domainId: data['domainId'] ?? '',
      currentRouteId: data['currentRouteId'],
      createdAt: data['createdAt'] != null ? DateTime.tryParse(data['createdAt']) ?? DateTime.now() : DateTime.now(),
      updatedAt: data['updatedAt'] != null ? DateTime.tryParse(data['updatedAt']) : null,
      // Defaulting legacy fields not in spec
      model: data['model'] ?? 'Toyota Hiace', 
      year: data['year'] ?? 2020,
      color: data['color'] ?? 'White',
    );
  }
}
