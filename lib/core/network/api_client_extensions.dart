import 'package:dio/dio.dart';
import 'package:komiut/core/errors/failures.dart';
import 'package:komiut/core/network/api_client.dart';

extension ApiClientDriverExtension on ApiClient {
  Future<dynamic> getDriver(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    final result = await get<dynamic>(path,
        queryParameters: queryParameters, options: options);
    return result.fold(
      (failure) => throw ServerFailure(failure.message),
      (data) => data,
    );
  }

  Future<dynamic> postDriver(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    final result = await post<dynamic>(path,
        data: data, queryParameters: queryParameters, options: options);
    return result.fold(
      (failure) => throw ServerFailure(failure.message),
      (data) => data,
    );
  }

  Future<dynamic> putDriver(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    final result = await put<dynamic>(path,
        data: data, queryParameters: queryParameters, options: options);
    return result.fold(
      (failure) => throw ServerFailure(failure.message),
      (data) => data,
    );
  }

  Future<dynamic> deleteDriver(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    final result = await delete<dynamic>(path,
        data: data, queryParameters: queryParameters, options: options);
    return result.fold(
      (failure) => throw ServerFailure(failure.message),
      (data) => data,
    );
  }
}

/// A compatibility class that mimics the old response.data behavior
class DriverResponse {
  final dynamic data;
  DriverResponse(this.data);
}
