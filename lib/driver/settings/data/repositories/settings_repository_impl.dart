import 'package:dartz/dartz.dart';

import 'package:komiut_app/core/errors/failures.dart';
import 'package:komiut_app/core/network/api_exceptions.dart';
import 'package:komiut_app/driver/dashboard/domain/entities/dashboard_entities.dart' show DriverProfile;
import 'package:komiut_app/driver/dashboard/data/models/dashboard_models.dart';
import 'package:komiut_app/driver/settings/domain/entities/driver_settings.dart';
import 'package:komiut_app/driver/settings/domain/repositories/settings_repository.dart';
import 'package:komiut_app/driver/settings/data/datasources/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, DriverSettings>> getSettings() async {
    try {
      final settings = await remoteDataSource.getSettings();
      return Right(settings);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DriverProfile>> updateProfile(Map<String, dynamic> data) async {
    try {
      final profile = await remoteDataSource.updateProfile(data);
      return Right(profile);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePreferences(AppPreferences preferences) async {
    // TODO: Implement actual preference update logic (local or remote)
    // For now, assuming success or simple local storage update if we had it.
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    // TODO: Implement logout logic (clear tokens, etc)
    return const Right(unit);
  }
}
