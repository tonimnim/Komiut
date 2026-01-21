import 'package:komiut_app/shared/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<String> login(String phone, [String? password]);

  Future<User> verifyOtp(String verificationId, String otp);

  Future<void> logout();

  Future<bool> isAuthenticated();

  Future<User?> getCurrentUser();

  Future<String?> getUserRole();

  Future<bool> refreshToken();
}
