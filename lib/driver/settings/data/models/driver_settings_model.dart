import 'package:komiut_app/driver/settings/domain/entities/driver_settings.dart';
import 'package:komiut_app/driver/dashboard/data/models/dashboard_models.dart';
// Note: dashboard/data/models might not exist yet if dashboard was partially implemented. 
// I will create simple local models if imports fail, but logically they belong in dashboard. 
// For now, let's implement the model assuming standard JSON structure.

class DriverSettingsModel extends DriverSettings {
  const DriverSettingsModel({
    required super.profile,
    required super.vehicle,
    required super.preferences,
  });

  factory DriverSettingsModel.fromJson(Map<String, dynamic> json) {
    // This assumes the API returns a composite object or we compose it from multiple calls
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
