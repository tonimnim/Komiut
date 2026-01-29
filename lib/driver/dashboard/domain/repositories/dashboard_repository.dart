import '../entities/dashboard_entities.dart';

abstract class DashboardRepository {
  Future<DriverProfile> getDriverProfile();

  Future<Vehicle> getVehicle();

  Future<Circle> getCircle();

  Future<CircleRoute> getRoute();

  Future<String> toggleStatus(String newStatus);

  Future<EarningsSummary> getTodayEarnings();
  Future<List<Map<String, dynamic>>> getNotifications();
  Future<void> markNotificationAsRead(String id);
  Future<int> getCurrentPassengers();
}
