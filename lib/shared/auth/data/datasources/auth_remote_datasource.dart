import 'package:komiut/core/network/api_client.dart';
import 'package:komiut/core/config/api_endpoints.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> registration(Map<String, dynamic> data);
  Future<Map<String, dynamic>> resetPassword(String phoneNumber);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.postDriver(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;
    final result =
        data is Map && data.containsKey('data') ? data['data'] : data;

    if (result is List) {
      return result.first as Map<String, dynamic>;
    }
    return result as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> registration(Map<String, dynamic> data) async {
    final response = await _apiClient.postDriver(
      ApiEndpoints.registration,
      data: data,
    );

    final responseData = response.data;
    final result = responseData is Map && responseData.containsKey('data')
        ? responseData['data']
        : responseData;

    if (result is List) {
      return result.first as Map<String, dynamic>;
    }
    return result as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> resetPassword(String phoneNumber) async {
    final response = await _apiClient.postDriver(
      ApiEndpoints.resetPassword,
      data: {
        'phoneNumber': phoneNumber,
      },
    );

    final data = response.data;
    final result =
        data is Map && data.containsKey('data') ? data['data'] : data;

    if (result is List) {
      return result.first as Map<String, dynamic>;
    }
    return result as Map<String, dynamic>;
  }
}
