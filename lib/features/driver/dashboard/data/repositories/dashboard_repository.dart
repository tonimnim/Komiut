import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../domain/entities/driver_profile.dart';
import '../../domain/entities/driver_stats.dart';
import '../datasources/dashboard_remote_datasource.dart';

/// Provider for dashboard repository.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final remoteDataSource = ref.watch(dashboardRemoteDataSourceProvider);
  return DashboardRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Abstract interface for dashboard repository.
abstract class DashboardRepository {
  /// Gets the driver's profile.
  Future<Either<Failure, DriverProfile>> getDriverProfile(String personnelId);

  /// Gets the driver's statistics.
  Future<Either<Failure, DriverStats>> getDriverStats(String vehicleId);

  /// Updates driver online status.
  Future<Either<Failure, void>> updateOnlineStatus({
    required String personnelId,
    required bool isOnline,
  });
}

/// Implementation of dashboard repository.
class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({required this.remoteDataSource});

  final DashboardRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, DriverProfile>> getDriverProfile(String personnelId) {
    return remoteDataSource.getDriverProfile(personnelId);
  }

  @override
  Future<Either<Failure, DriverStats>> getDriverStats(String vehicleId) {
    return remoteDataSource.getDriverStats(vehicleId);
  }

  @override
  Future<Either<Failure, void>> updateOnlineStatus({
    required String personnelId,
    required bool isOnline,
  }) {
    return remoteDataSource.updateOnlineStatus(
      personnelId: personnelId,
      isOnline: isOnline,
    );
  }
}
