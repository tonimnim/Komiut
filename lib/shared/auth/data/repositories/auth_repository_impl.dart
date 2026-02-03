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
  Future<void> login(String email, String password) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    final data = await remoteDataSource.login(email, password);
    await _saveLoginData(data);
  }

  @override
  Future<void> register({
    required String email,
    required String phoneNumber,
    required String password,
    required String userName,
  }) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    final data = await remoteDataSource.registration({
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'confirmPassword': password,
      'userName': userName,
    });
    await _saveLoginData(data);
  }

  @override
  Future<void> resetPassword(String phoneNumber) async {
    if (!await networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    await remoteDataSource.resetPassword(phoneNumber);
  }

  Future<void> _saveLoginData(Map<String, dynamic> data) async {
    final accessToken = (data['accessToken'] ?? data['access_token']) as String;
    final refreshToken =
        (data['refreshToken'] ?? data['refresh_token']) as String;

    await localDataSource.saveTokens(accessToken, refreshToken);

    final userJson = data['user'] ?? data;
    final userModel = UserModel.fromJson(userJson as Map<String, dynamic>);
    await localDataSource.saveUser(userModel);
  }

  @override
  Future<void> logout() async {
    try {
      // Local cleanup only as logout is not in the shared spec
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
}
