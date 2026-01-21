import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/driver_settings.dart';
import 'package:komiut_app/driver/dashboard/domain/entities/dashboard_entities.dart' show DriverProfile;

abstract class SettingsRepository {
  Future<Either<Failure, DriverSettings>> getSettings();
  Future<Either<Failure, DriverProfile>> updateProfile(Map<String, dynamic> data);
  Future<Either<Failure, Unit>> updatePreferences(AppPreferences preferences);
  Future<Either<Failure, Unit>> logout();
}
