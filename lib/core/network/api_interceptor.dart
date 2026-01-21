import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_constants.dart';
import '../config/api_endpoints.dart';

class ApiInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  ApiInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final noAuthPaths = [
      ApiEndpoints.login,
      ApiEndpoints.verifyOtp,
    ];

    if (!noAuthPaths.contains(options.path)) {
      final token = await _storage.read(key: AppConstants.keyAccessToken);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        try {
          final token = await _storage.read(key: AppConstants.keyAccessToken);
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          
          final dio = Dio();
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
        }
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: AppConstants.keyRefreshToken);
      if (refreshToken == null) return false;

      final dio = Dio();
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await _storage.write(
          key: AppConstants.keyAccessToken,
          value: data['access_token'],
        );
        await _storage.write(
          key: AppConstants.keyRefreshToken,
          value: data['refresh_token'],
        );
        return true;
      }
    } catch (e) {
    }
    return false;
  }
}
