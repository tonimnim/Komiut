import 'package:dio/dio.dart';

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
        '/api/trips/start',
        data: {
          'route_id': routeId,
          'vehicle_id': vehicleId,
        },
      );
      return TripModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<TripModel> updateTripStatus(String tripId, String status, {Map<String, dynamic>? data}) async {
    try {
      final Map<String, dynamic> body = {'status': status};
      if (data != null) body.addAll(data);
      
      final response = await apiClient.put(
        '/api/trips/$tripId/status',
        data: body,
      );
      return TripModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<TripModel> endTrip(String tripId, {required int finalPassengers, required double finalEarnings}) async {
    try {
      final response = await apiClient.post(
        '/api/trips/$tripId/end',
        data: {
          'passenger_count': finalPassengers,
          'earnings': finalEarnings,
        },
      );
      return TripModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<TripModel?> getActiveTrip() async {
    try {
      final response = await apiClient.get('/api/trips/active');
      if (response.data['data'] == null) return null;
      return TripModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null; // No active trip
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<TripModel> getTripById(String tripId) async {
    try {
      final response = await apiClient.get('/api/trips/$tripId');
      return TripModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
