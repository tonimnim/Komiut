import 'package:komiut/shared/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<void> login(String email, String password);

  Future<void> register({
    required String email,
    required String phoneNumber,
    required String password,
    required String userName,
  });

  Future<void> resetPassword(String phoneNumber);

  Future<void> logout();

  Future<bool> isAuthenticated();

  Future<User?> getCurrentUser();

  Future<String?> getUserRole();
}
