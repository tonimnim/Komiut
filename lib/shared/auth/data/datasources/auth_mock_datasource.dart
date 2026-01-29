import 'package:komiut/shared/auth/data/datasources/auth_remote_datasource.dart';

class AuthMockDataSource implements AuthRemoteDataSource {
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'access_token': 'mock-access-token',
      'refresh_token': 'mock-refresh-token',
      'user': {
        'id': 'mock-user-id',
        'name': 'Musa Mwange',
        'phone': '0114945842',
        'email': email,
        'role': 'driver',
        'profile_image': 'https://i.pravatar.cc/150?u=mockdriver',
      }
    };
  }

  @override
  Future<Map<String, dynamic>> registration(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'access_token': 'mock-access-token',
      'refresh_token': 'mock-refresh-token',
      'user': {
        'id': 'mock-user-id',
        'name': data['userName'] ?? 'New User',
        'phone': data['phoneNumber'] ?? '0114945842',
        'email': data['email'] ?? 'newuser@komiut.com',
        'role': 'driver',
        'profile_image': 'https://i.pravatar.cc/150?u=mockdriver',
      }
    };
  }

  @override
  Future<Map<String, dynamic>> resetPassword(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {'success': true};
  }
}
