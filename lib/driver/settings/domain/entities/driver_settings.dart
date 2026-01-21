import 'package:equatable/equatable.dart';

import 'package:komiut_app/driver/dashboard/domain/entities/dashboard_entities.dart';

class DriverSettings extends Equatable {
  final DriverProfile profile;
  final Vehicle vehicle;
  final AppPreferences preferences;

  const DriverSettings({
    required this.profile,
    required this.vehicle,
    required this.preferences,
  });

  @override
  List<Object?> get props => [profile, vehicle, preferences];
}

class AppPreferences extends Equatable {
  final bool isDarkMode;
  final bool notificationsEnabled;

  const AppPreferences({
    required this.isDarkMode,
    required this.notificationsEnabled,
  });

  @override
  List<Object?> get props => [isDarkMode, notificationsEnabled];
}
