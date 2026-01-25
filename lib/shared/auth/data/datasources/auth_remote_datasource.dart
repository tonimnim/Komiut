import 'package:komiut_app/core/network/api_client.dart';
import 'package:komiut_app/core/config/api_endpoints.dart';
import 'package:komiut_app/shared/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String phone, [String? password]);
  Future<Map<String, dynamic>> verifyOtp(String verificationId, String otp);
  Future<void> logout();
  Future<Map<String, dynamic>> refreshToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> login(String phoneOrEmail, [String? password]) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': phoneOrEmail, // v2 Swagger uses 'email' in MobileLoginCommand
        'password': password ?? '',
      },
    );

    final data = response.data;
    // v2 returns directly or wrapped
    final result = data is Map && data.containsKey('data') ? data['data'] : data;
    
    if (result is List) {
      return result.first as Map<String, dynamic>;
    }
    return result as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String verificationId, String otp) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {
        'verification_id': verificationId,
        'otp': otp,
      },
    );

    final data = response.data;
    if (data['success'] == true) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception(data['error']?['message'] ?? 'OTP verification failed');
  }

  @override
  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout);
  }

  @override
  Future<Map<String, dynamic>> refreshToken() async {
    final response = await _apiClient.post(ApiEndpoints.refreshToken);
    return response.data['data'] as Map<String, dynamic>;
  }
}
