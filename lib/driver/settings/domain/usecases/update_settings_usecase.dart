import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../driver/dashboard/domain/entities/dashboard_entities.dart';
import '../repositories/settings_repository.dart';

class UpdateProfileUseCase {
  final SettingsRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, DriverProfile>> call(Map<String, dynamic> data) async {
    return await repository.updateProfile(data);
  }
}
