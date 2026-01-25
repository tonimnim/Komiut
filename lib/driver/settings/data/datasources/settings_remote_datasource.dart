import 'package:dio/dio.dart';
import 'package:komiut_app/core/config/api_endpoints.dart';

import 'package:komiut_app/core/network/api_client.dart';
import 'package:komiut_app/core/network/api_exceptions.dart';
import 'package:komiut_app/driver/dashboard/data/models/dashboard_models.dart';
import 'package:komiut_app/driver/settings/data/models/driver_settings_model.dart';

abstract class SettingsRemoteDataSource {
  Future<DriverSettingsModel> getSettings();
  Future<DriverProfileModel> updateProfile(Map<String, dynamic> data);
  Future<DriverProfileModel> uploadProfilePicture(String filePath);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final ApiClient apiClient;

  SettingsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<DriverSettingsModel> getSettings() async {
    try {
      final profileResponse = await apiClient.get(ApiEndpoints.driverProfile);
      final vehicleResponse = await apiClient.get(ApiEndpoints.driverVehicle);
      
      final profileData = profileResponse.data is Map && profileResponse.data.containsKey('data') 
          ? profileResponse.data['data'] 
          : (profileResponse.data is List ? profileResponse.data.first : profileResponse.data);
          
      final vehicleData = vehicleResponse.data is Map && vehicleResponse.data.containsKey('data') 
          ? vehicleResponse.data['data'] 
          : (vehicleResponse.data is List ? vehicleResponse.data.first : vehicleResponse.data);

      final Map<String, dynamic> compositeJson = {
        'profile': profileData,
        'vehicle': vehicleData,
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
      final response = await apiClient.put(
        ApiEndpoints.driverProfile,
        data: data,
      );
      final responseData = response.data is Map && response.data.containsKey('data') 
          ? response.data['data'] 
          : response.data;
      return DriverProfileModel.fromJson(responseData);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<DriverProfileModel> uploadProfilePicture(String filePath) async {
    try {
      final response = await apiClient.uploadFile(
        ApiEndpoints.driverProfilePhoto,
        filePath: filePath,
        fieldName: 'photo',
      );
      final responseData = response.data is Map && response.data.containsKey('data') 
          ? response.data['data'] 
          : response.data;
      return DriverProfileModel.fromJson(responseData);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
