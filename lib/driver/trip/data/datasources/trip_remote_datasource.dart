import 'package:dio/dio.dart';
import 'package:komiut_app/core/config/api_endpoints.dart';

import 'package:komiut_app/core/network/api_client.dart';
import 'package:komiut_app/core/network/api_exceptions.dart';
import 'package:komiut_app/driver/trip/data/models/trip_model.dart';

abstract class TripRemoteDataSource {
  Future<TripModel> startTrip(String routeId, String vehicleId);
  Future<TripModel> updateTripStatus(String tripId, String status, {Map<String, dynamic>? data});
  Future<TripModel> endTrip(String tripId, {required int finalPassengers, required double finalEarnings});
  Future<TripModel?> getActiveTrip();
  Future<TripModel> getTripById(String tripId);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final ApiClient apiClient;

  TripRemoteDataSourceImpl(this.apiClient);

  @override
  Future<TripModel> startTrip(String routeId, String vehicleId) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.tripStart,
        data: {
          'routeId': routeId,
          'vehicleId': vehicleId,
        },
      );
      final data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      return TripModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<TripModel> updateTripStatus(String tripId, String status, {Map<String, dynamic>? data}) async {
    try {
      final Map<String, dynamic> body = {
        'tripId': tripId,
        'status': status is int ? status : (status == 'active' ? 1 : (status == 'ended' ? 2 : 0)),
      };
      if (data != null) body.addAll(data);
      
      final response = await apiClient.put(
        ApiEndpoints.tripUpdate(tripId),
        data: body,
      );
      final responseData = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      return TripModel.fromJson(responseData);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<TripModel> endTrip(String tripId, {required int finalPassengers, required double finalEarnings}) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.tripEnd(tripId),
        data: {
          'passengerCount': finalPassengers,
          'earnings': finalEarnings,
        },
      );
      final data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      return TripModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<TripModel?> getActiveTrip() async {
    try {
      final response = await apiClient.get(ApiEndpoints.tripActive);
      final data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      if (data == null || (data is List && data.isEmpty)) return null;
      final result = data is List ? data.first : data;
      return TripModel.fromJson(result);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<TripModel> getTripById(String tripId) async {
    try {
      final response = await apiClient.get(ApiEndpoints.tripDetails(tripId));
      final data = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;
      return TripModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
