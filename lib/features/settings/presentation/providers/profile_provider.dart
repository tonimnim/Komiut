import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../../core/database/database_providers.dart';

class ProfileService {
  final Ref _ref;

  ProfileService(this._ref);

  Future<bool> updateProfile({
    required int userId,
    required String fullName,
    String? phone,
    String? profileImage,
  }) async {
    try {
      final database = _ref.read(appDatabaseProvider);
      return await database.updateUserProfile(
        userId,
        fullName: fullName,
        phone: phone,
        profileImage: profileImage,
      );
    } catch (e) {
      return false;
    }
  }

  Future<String?> saveProfileImage(File imageFile, int userId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDir.path}/profile_images');

      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      final extension = path.extension(imageFile.path);
      final fileName = 'profile_$userId$extension';
      final savedPath = '${profileDir.path}/$fileName';

      await imageFile.copy(savedPath);
      return savedPath;
    } catch (e) {
      return null;
    }
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref);
});
