import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:komiut/core/errors/failures.dart';
import 'package:komiut/core/network/api_exceptions.dart';
import 'package:komiut/driver/dashboard/domain/entities/dashboard_entities.dart' show DriverProfile;
import 'package:komiut/driver/dashboard/data/models/dashboard_models.dart';
import 'package:komiut/driver/settings/domain/entities/driver_settings.dart';
import 'package:komiut/driver/settings/domain/repositories/settings_repository.dart';
import 'package:komiut/driver/settings/data/datasources/settings_remote_datasource.dart';

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
  Future<Either<Failure, DriverProfile>> uploadProfilePicture(String filePath) async {
    try {
      final profile = await remoteDataSource.uploadProfilePicture(filePath);
      return Right(profile);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeProfilePicture() async {
    try {
      await remoteDataSource.updateProfile({'imageUrl': null});
      return const Right(unit);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePreferences(AppPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', preferences.isDarkMode);
      await prefs.setBool('notificationsEnabled', preferences.notificationsEnabled);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    return const Right(unit);
  }
}
