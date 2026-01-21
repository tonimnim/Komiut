import 'package:dio/dio.dart';

import 'package:komiut_app/core/network/api_client.dart';
import 'package:komiut_app/core/network/api_exceptions.dart';
import 'package:komiut_app/driver/dashboard/data/models/dashboard_models.dart';
import 'package:komiut_app/driver/settings/data/models/driver_settings_model.dart';

abstract class SettingsRemoteDataSource {
  Future<DriverSettingsModel> getSettings(); // Likely a composite of profile + vehicle + local prefs
  Future<DriverProfileModel> updateProfile(Map<String, dynamic> data);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final ApiClient apiClient;

  SettingsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<DriverSettingsModel> getSettings() async {
    try {
      // In a real scenario, this might be multiple calls (profile, vehicle).
      // For simplicity, assuming a wrapper endpoint or sequential calls.
      final profileResponse = await apiClient.get('/api/driver/profile');
      final vehicleResponse = await apiClient.get('/api/driver/vehicle');
      
      // Construct composite JSON for the model
      final Map<String, dynamic> compositeJson = {
        'profile': profileResponse.data['data'],
        'vehicle': vehicleResponse.data['data'],
        'preferences': {}, // Preferences usually local, but maybe synced
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
        '/api/driver/profile',
        data: data,
      );
      return DriverProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
