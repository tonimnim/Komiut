import 'package:komiut_app/shared/auth/data/datasources/auth_remote_datasource.dart';

class AuthMockDataSource implements AuthRemoteDataSource {
  @override
  Future<String> login(String phone, [String? password]) async {
    await Future.delayed(const Duration(seconds: 1));
    return "mock-verification-id";
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String verificationId, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulated successful OTP verification response
    return {
      'access_token': 'mock-access-token',
      'refresh_token': 'mock-refresh-token',
      'user': {
        'id': 'mock-user-id',
        'name': 'Mock Driver',
        'phone': '+254114945842',
        'email': 'driver@komiut.com',
        'role': 'driver',
        'profile_image': 'https://i.pravatar.cc/150?u=mockdriver',
      }
    };
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<Map<String, dynamic>> refreshToken() async {
    return {
      'access_token': 'new-mock-access-token',
      'refresh_token': 'new-mock-refresh-token',
    };
  }
}
