import 'package:komiut/core/network/network_info.dart';
import 'package:komiut/shared/auth/domain/entities/user.dart';
import 'package:komiut/shared/auth/domain/repositories/auth_repository.dart';
import 'package:komiut/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:komiut/shared/auth/data/datasources/auth_local_datasource.dart';
import 'package:komiut/shared/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<String> login(String phone, [String? password]) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    final data = await remoteDataSource.login(phone, password);
    
    // Check if we got tokens immediately (v2 flow)
    if (data.containsKey('accessToken') || data.containsKey('access_token')) {
      await _saveLoginData(data);
      return 'SUCCESS'; // Special signal for UI that we logged in directly
    }
    
    // Otherwise assume it's a verification ID
    return data['verification_id'] ?? data['id'] ?? '';
  }

  Future<void> _saveLoginData(Map<String, dynamic> data) async {
    final accessToken = (data['accessToken'] ?? data['access_token']) as String;
    final refreshToken = (data['refreshToken'] ?? data['refresh_token']) as String;
    
    await localDataSource.saveTokens(accessToken, refreshToken);

    final userJson = data['user'] ?? data;
    final userModel = UserModel.fromJson(userJson as Map<String, dynamic>);
    await localDataSource.saveUser(userModel);
  }

  @override
  Future<User> verifyOtp(String verificationId, String otp) async {
    if (verificationId == 'SUCCESS') {
      // Already logged in via direct password
      final user = await localDataSource.getUser();
      if (user != null) return user;
      throw Exception('User data not found');
    }

    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }

    final data = await remoteDataSource.verifyOtp(verificationId, otp);
    await _saveLoginData(data);

    return await localDataSource.getUser() as User;
  }

  @override
  Future<void> logout() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }
    } finally {
      await localDataSource.clearTokens();
      await localDataSource.clearUser();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await localDataSource.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<User?> getCurrentUser() async {
    return await localDataSource.getUser();
  }

  @override
  Future<String?> getUserRole() async {
    final user = await localDataSource.getUser();
    return user?.role;
  }

  @override
  Future<bool> refreshToken() async {
    try {
      if (!await networkInfo.isConnected) return false;
      
      final data = await remoteDataSource.refreshToken();
      await localDataSource.saveTokens(
        data['access_token'] as String,
        data['refresh_token'] as String,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
