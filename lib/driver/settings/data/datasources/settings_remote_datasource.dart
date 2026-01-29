import 'package:dio/dio.dart';
import 'package:komiut/core/config/api_endpoints.dart';

import 'package:komiut/core/network/api_client.dart';
import 'package:komiut/core/network/api_exceptions.dart';
import 'package:komiut/core/errors/failures.dart';
import 'package:komiut/driver/dashboard/data/models/dashboard_models.dart';
import 'package:komiut/driver/settings/data/models/driver_settings_model.dart';

abstract class SettingsRemoteDataSource {
  Future<DriverSettingsModel> getSettings();
  Future<DriverProfileModel> updateProfile(Map<String, dynamic> data);
  Future<DriverProfileModel> uploadProfilePicture(String filePath);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final ApiClient apiClient;

  SettingsRemoteDataSourceImpl(this.apiClient);

  Future<T> _unwrap<T>(Future<dynamic> request) async {
    final result = await request;
    return result.fold(
      (failure) => throw ServerFailure(failure.message),
      (data) => data as T,
    );
  }

  @override
  Future<DriverSettingsModel> getSettings() async {
    try {
      final profileData = await _unwrap<dynamic>(apiClient.getDriver(ApiEndpoints.personnel));
      final vehicleData = await _unwrap<dynamic>(apiClient.getDriver(ApiEndpoints.vehicles));
      
      final processedProfile = profileData is Map && profileData.containsKey('data') 
          ? profileData['data'] 
          : (profileData is List ? (profileData.isNotEmpty ? profileData.first : {}) : profileData);
          
      final processedVehicle = vehicleData is Map && vehicleData.containsKey('data') 
          ? vehicleData['data'] 
          : (vehicleData is List ? (vehicleData.isNotEmpty ? vehicleData.first : {}) : vehicleData);

      final Map<String, dynamic> compositeJson = {
        'profile': processedProfile,
        'vehicle': processedVehicle,
        'preferences': {},
      };
      
      return DriverSettingsModel.fromJson(compositeJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<DriverProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final responseData = await _unwrap<dynamic>(apiClient.putDriver(
        ApiEndpoints.personnel,
        data: data,
      ));
      
      final processedData = responseData is Map && responseData.containsKey('data') 
          ? responseData['data'] 
          : responseData;
      return DriverProfileModel.fromJson(processedData);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<DriverProfileModel> uploadProfilePicture(String filePath) async {
    try {
      final responseData = await _unwrap<dynamic>(apiClient.uploadFile(
        ApiEndpoints.personnel,
        filePath: filePath,
        fieldName: 'photo',
      ));
      
      final processedData = responseData is Map && responseData.containsKey('data') 
          ? responseData['data'] 
          : responseData;
      return DriverProfileModel.fromJson(processedData);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
