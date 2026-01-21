import 'package:komiut_app/core/network/network_info.dart';
import 'package:komiut_app/shared/auth/domain/entities/user.dart';
import 'package:komiut_app/shared/auth/domain/repositories/auth_repository.dart';
import 'package:komiut_app/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:komiut_app/shared/auth/data/datasources/auth_local_datasource.dart';
import 'package:komiut_app/shared/auth/data/models/user_model.dart';

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
    return await remoteDataSource.login(phone, password);
  }

  @override
  Future<User> verifyOtp(String verificationId, String otp) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }

    final data = await remoteDataSource.verifyOtp(verificationId, otp);
    
    await localDataSource.saveTokens(
      data['access_token'] as String,
      data['refresh_token'] as String,
    );

    final userModel = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await localDataSource.saveUser(userModel);

    return userModel;
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
