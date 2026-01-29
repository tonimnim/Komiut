import 'package:komiut/driver/settings/domain/entities/driver_settings.dart';
import 'package:komiut/driver/dashboard/data/models/dashboard_models.dart';


class DriverSettingsModel extends DriverSettings {
  const DriverSettingsModel({
    required super.profile,
    required super.vehicle,
    required super.preferences,
  });

  factory DriverSettingsModel.fromJson(Map<String, dynamic> json) {
    return DriverSettingsModel(
      profile: DriverProfileModel.fromJson(json['profile']),
      vehicle: VehicleModel.fromJson(json['vehicle']),
      preferences: AppPreferencesModel.fromJson(json['preferences'] ?? {}),
    );
  }
}

class AppPreferencesModel extends AppPreferences {
  const AppPreferencesModel({
    required super.isDarkMode,
    required super.notificationsEnabled,
  });

  factory AppPreferencesModel.fromJson(Map<String, dynamic> json) {
    return AppPreferencesModel(
      isDarkMode: json['dark_mode'] ?? false,
      notificationsEnabled: json['notifications_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dark_mode': isDarkMode,
      'notifications_enabled': notificationsEnabled,
    };
  }
}
