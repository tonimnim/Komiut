import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../driver/dashboard/domain/entities/dashboard_entities.dart';
import '../repositories/settings_repository.dart';

class UploadProfilePictureUseCase {
  final SettingsRepository repository;

  UploadProfilePictureUseCase(this.repository);

  Future<Either<Failure, DriverProfile>> call(String filePath) async {
    return await repository.uploadProfilePicture(filePath);
  }
}
