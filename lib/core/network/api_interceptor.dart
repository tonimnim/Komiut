import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import '../config/app_constants.dart';
import 'api_endpoints.dart';

class ApiInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  ApiInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add domain header for white-label backend identification
    options.headers['_domain'] = AppConstants.domainId;

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

          final retryDio = Dio(BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              '_domain': AppConstants.domainId,
            },
          ));
          final response = await retryDio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {
          // Retry failed, continue with original error
        }
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken =
          await _storage.read(key: AppConstants.keyRefreshToken);
      if (refreshToken == null) return false;

      final refreshDio = Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          '_domain': AppConstants.domainId,
        },
      ));
      final response = await refreshDio.post(
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
    } catch (_) {
      // Token refresh failed
    }
    return false;
  }
}
