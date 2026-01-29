import 'package:dio/dio.dart';
import 'package:komiut/core/config/api_endpoints.dart';
import 'package:komiut/core/network/api_client.dart';
import 'package:komiut/core/network/api_exceptions.dart';

abstract class RouteRemoteDataSource {
  Future<dynamic> getRoutes(); // dynamic for now as we might need a RouteModel
  Future<void> createRoute(Map<String, dynamic> routeData);
}

class RouteRemoteDataSourceImpl implements RouteRemoteDataSource {
  final ApiClient apiClient;

  RouteRemoteDataSourceImpl(this.apiClient);

  @override
  Future<dynamic> getRoutes() async {
    try {
      final response = await apiClient.getDriver(
        ApiEndpoints.routes,
      );
      return response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> createRoute(Map<String, dynamic> routeData) async {
    try {
      await apiClient.postDriver(
        ApiEndpoints.routes,
        data: routeData,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
