import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/driver_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;

  GetSettingsUseCase(this.repository);

  Future<Either<Failure, DriverSettings>> call() async {
    return await repository.getSettings();
  }
}
