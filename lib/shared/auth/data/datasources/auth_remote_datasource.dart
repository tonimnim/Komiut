import 'package:komiut_app/core/network/api_client.dart';
import 'package:komiut_app/core/config/api_endpoints.dart';
import 'package:komiut_app/shared/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(String phone, [String? password]);
  Future<Map<String, dynamic>> verifyOtp(String verificationId, String otp);
  Future<void> logout();
  Future<Map<String, dynamic>> refreshToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<String> login(String phone, [String? password]) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'phone': phone,
        if (password != null) 'password': password,
      },
    );

    final data = response.data;
    if (data['success'] == true) {
      return data['data']['verification_id'] as String;
    }
    throw Exception(data['error']?['message'] ?? 'Login failed');
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
