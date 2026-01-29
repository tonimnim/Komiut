import 'package:komiut/driver/dashboard/data/models/dashboard_models.dart';
import 'package:komiut/driver/settings/data/datasources/settings_remote_datasource.dart';
import 'package:komiut/driver/settings/data/models/driver_settings_model.dart';

class SettingsMockDataSource implements SettingsRemoteDataSource {
  @override
  Future<DriverSettingsModel> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DriverSettingsModel(
      profile: DriverProfileModel(
        id: 'mock-driver-123',
        organizationId: 'mock-org-123',
        name: 'Musa M',
        email: 'musa@komiut.com',
        phone: '+254114945842',
        status: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        rating: 4.8,
        totalTrips: 156,
      ),
      vehicle: VehicleModel(
        id: 'mock-vehicle-123',
        registrationNumber: const RegistrationNumberModel(value: 'KBD 123X'),
        capacity: 14,
        status: 'active',
        organizationId: 'mock-org-123',
        domainId: 'mock-domain-123',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        model: 'Toyota Hiace',
        year: 2020,
        color: 'White',
        type: 'Matatu',
        insuranceExpiry: DateTime.now().add(const Duration(days: 120)),
        inspectionExpiry: DateTime.now().add(const Duration(days: 45)),
      ),
      preferences: const AppPreferencesModel(
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
      organizationId: 'mock-org-123',
      name: data['name'] ?? 'Musa M',
      email: data['email'] ?? 'musa@komiut.com',
      phone: data['phone'] ?? '+254114945842',
      status: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  @override
  Future<DriverProfileModel> uploadProfilePicture(String filePath) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DriverProfileModel(
      id: 'mock-driver-123',
      organizationId: 'mock-org-123',
      name: 'Musa M',
      email: 'musa@komiut.com',
      phone: '+254114945842',
      status: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      imageUrl: 'https://via.placeholder.com/150',
    );
  }
}
