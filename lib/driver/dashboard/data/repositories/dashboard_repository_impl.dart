import 'package:komiut_app/core/network/network_info.dart';
import 'package:komiut_app/driver/dashboard/domain/entities/dashboard_entities.dart';
import 'package:komiut_app/driver/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:komiut_app/driver/dashboard/data/datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<DriverProfile> getDriverProfile() async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    return await remoteDataSource.getDriverProfile();
  }

  @override
  Future<Vehicle> getVehicle() async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    return await remoteDataSource.getVehicle();
  }

  @override
  Future<Circle> getCircle() async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    return await remoteDataSource.getCircle();
  }

  @override
  Future<CircleRoute> getRoute() async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    return await remoteDataSource.getRoute();
  }

  @override
  Future<String> toggleStatus(String newStatus) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    return await remoteDataSource.toggleStatus(newStatus);
  }

  @override
  Future<EarningsSummary> getTodayEarnings() async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    return await remoteDataSource.getTodayEarnings();
  }

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    return await remoteDataSource.getNotifications();
  }

  @override
  Future<int> getCurrentPassengers() async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    return await remoteDataSource.getCurrentPassengers();
  }
}
