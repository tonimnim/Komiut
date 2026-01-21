import 'package:komiut_app/driver/dashboard/data/models/dashboard_models.dart';
import 'package:komiut_app/driver/settings/data/datasources/settings_remote_datasource.dart';
import 'package:komiut_app/driver/settings/data/models/driver_settings_model.dart';

class SettingsMockDataSource implements SettingsRemoteDataSource {
  @override
  Future<DriverSettingsModel> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const DriverSettingsModel(
      profile: DriverProfileModel(
        id: 'mock-driver-123',
        name: 'Musa Mwange',
        email: 'musa@komiut.com',
        phone: '+254114945842',
        status: 'live',
        profileImage: 'https://i.pravatar.cc/150?u=musa',
        rating: 4.8,
        totalTrips: 156,
      ),
      vehicle: VehicleModel(
        id: 'mock-vehicle-123',
        plateNumber: 'KBD 123X',
        model: 'Toyota Hiace',
        capacity: 14,
        color: 'White',
        type: 'Bus',
        year: 2022,
        status: 'active',
      ),
      preferences: AppPreferencesModel(
        isDarkMode: false,
        notificationsEnabled: true,
      ),
    );
  }

  @override
  Future<DriverProfileModel> updateProfile(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DriverProfileModel(
      id: 'mock-driver-123',
      name: data['name'] ?? 'Musa Mwange',
      email: data['email'] ?? 'musa@komiut.com',
      phone: data['phone'] ?? '+254114945842',
      status: 'live',
      profileImage: 'https://i.pravatar.cc/150?u=musa',
      rating: 4.8,
      totalTrips: 156,
    );
  }
}
