import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._secureStorage, this._prefs);

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(
      key: AppConstants.keyAccessToken,
      value: accessToken,
    );
    await _secureStorage.write(
      key: AppConstants.keyRefreshToken,
      value: refreshToken,
    );
  }

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.keyAccessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.keyRefreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.keyAccessToken);
    await _secureStorage.delete(key: AppConstants.keyRefreshToken);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(AppConstants.keyUserData, user.toJsonString());
  }

  @override
  Future<UserModel?> getUser() async {
    final jsonString = _prefs.getString(AppConstants.keyUserData);
    if (jsonString != null) {
      return UserModel.fromJsonString(jsonString);
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await _prefs.remove(AppConstants.keyUserData);
  }
}
