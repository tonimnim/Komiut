import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../../../core/database/database_providers.dart';

class ProfileService {
  final Ref _ref;

  ProfileService(this._ref);

  /// Updates user profile locally and in secure storage.
  ///
  /// [userId] - The user's ID (String for API compatibility)
  Future<bool> updateProfile({
    required String userId,
    required String fullName,
    String? phone,
    String? profileImage,
  }) async {
    try {
      // Try to update in local database (for legacy support)
      final intId = int.tryParse(userId);
      if (intId != null) {
        final database = _ref.read(appDatabaseProvider);
        await database.updateUserProfile(
          intId,
          fullName: fullName,
          phone: phone,
          profileImage: profileImage,
        );
      }

      // Also update in secure storage for session persistence
      const storage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );
      await storage.write(key: 'user_name', value: fullName);
      if (phone != null) {
        await storage.write(key: 'user_phone', value: phone);
      }
      if (profileImage != null) {
        await storage.write(key: 'user_profile_image', value: profileImage);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Saves profile image to local storage.
  ///
  /// [userId] - The user's ID (String for API compatibility)
  Future<String?> saveProfileImage(File imageFile, String userId) async {
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
