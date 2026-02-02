import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/driver_profile.dart';
import '../../domain/entities/driver_stats.dart';
import '../models/driver_profile_model.dart';
import '../models/driver_stats_model.dart';

/// Provider for dashboard remote data source.
final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRemoteDataSourceImpl(apiClient: apiClient);
});

/// Abstract interface for dashboard data operations.
abstract class DashboardRemoteDataSource {
  /// Fetches the current driver's profile.
  Future<Either<Failure, DriverProfile>> getDriverProfile(String personnelId);

  /// Fetches driver statistics.
  Future<Either<Failure, DriverStats>> getDriverStats(String vehicleId);

  /// Updates driver online status.
  Future<Either<Failure, void>> updateOnlineStatus({
    required String personnelId,
    required bool isOnline,
  });
}

/// Implementation of dashboard remote data source.
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Either<Failure, DriverProfile>> getDriverProfile(
      String personnelId) async {
    return apiClient.get<DriverProfile>(
      ApiEndpoints.personnel,
      queryParameters: {'Id': personnelId},
      fromJson: (data) {
        if (data is List && data.isNotEmpty) {
          return DriverProfileModel.fromJson(
            data.first as Map<String, dynamic>,
          ).toEntity();
        }
        if (data is Map<String, dynamic>) {
          return DriverProfileModel.fromJson(data).toEntity();
        }
        throw Exception('Invalid response format');
      },
    );
  }

  @override
  Future<Either<Failure, DriverStats>> getDriverStats(String vehicleId) async {
    return apiClient.get<DriverStats>(
      ApiEndpoints.dailyVehicleTotals,
      queryParameters: {'VehicleId': vehicleId},
      fromJson: (data) {
        if (data is List) {
          return DriverStatsModel.fromDailyTotals(data).toEntity();
        }
        return DriverStatsModel.fromJson(
          data as Map<String, dynamic>,
        ).toEntity();
      },
    );
  }

  @override
  Future<Either<Failure, void>> updateOnlineStatus({
    required String personnelId,
    required bool isOnline,
  }) async {
    return apiClient.put<void>(
      ApiEndpoints.personnel,
      data: {
        'id': personnelId,
        'role': {'isActive': isOnline},
      },
    );
  }
}
